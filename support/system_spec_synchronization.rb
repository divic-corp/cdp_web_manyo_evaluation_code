# frozen_string_literal: true

module ManyoSystemSpecSynchronization
  REQUEST_START_GRACE = 0.35
  QUIET_PERIOD = 0.15
  WAIT_TIMEOUT = 10.0

  @mutex = Mutex.new
  @condition = ConditionVariable.new
  @active_requests = 0
  @completed_requests = 0
  @last_activity_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  class << self
    def snapshot
      @mutex.synchronize { @completed_requests }
    end

    def request_started
      @mutex.synchronize do
        @active_requests += 1
        @last_activity_at = monotonic_time
        @condition.broadcast
      end
    end

    def request_finished
      @mutex.synchronize do
        @active_requests -= 1 if @active_requests.positive?
        @completed_requests += 1
        @last_activity_at = monotonic_time
        @condition.broadcast
      end
    end

    def wait_for_request_cycle(after:, required: false, timeout: WAIT_TIMEOUT)
      started_deadline = monotonic_time + REQUEST_START_GRACE
      overall_deadline = monotonic_time + timeout
      observed_request = false

      @mutex.synchronize do
        loop do
          now = monotonic_time
          observed_request ||= @completed_requests > after
          quiet = @active_requests.zero? && (now - @last_activity_at) >= QUIET_PERIOD

          return true if observed_request && quiet
          return false if now >= overall_deadline
          return false if !required && !observed_request && now >= started_deadline

          next_deadline = if observed_request
                            [overall_deadline, @last_activity_at + QUIET_PERIOD].min
                          else
                            [overall_deadline, started_deadline].min
                          end
          @condition.wait(@mutex, [next_deadline - now, 0.01].max)
        end
      end
    end

    def wait_until_idle(timeout: WAIT_TIMEOUT)
      deadline = monotonic_time + timeout

      @mutex.synchronize do
        loop do
          now = monotonic_time
          quiet = @active_requests.zero? && (now - @last_activity_at) >= QUIET_PERIOD
          return true if quiet
          return false if now >= deadline

          next_deadline = [deadline, @last_activity_at + QUIET_PERIOD].min
          @condition.wait(@mutex, [next_deadline - now, 0.01].max)
        end
      end
    end

    def wait_for_document_ready(timeout: WAIT_TIMEOUT)
      session = Capybara.current_session
      browser = session.driver.browser
      deadline = monotonic_time + timeout

      loop do
        begin
          return true if browser.execute_script('return document.readyState') == 'complete'
        rescue Selenium::WebDriver::Error::StaleElementReferenceError,
               Selenium::WebDriver::Error::JavascriptError
          # The browser is replacing the document. Retry until it becomes stable.
        rescue Selenium::WebDriver::Error::UnknownError => e
          raise unless transient_document_error?(e)
        end

        return false if monotonic_time >= deadline

        sleep Capybara.default_retry_interval
      end
    end

    def clean_database!
      connection = ActiveRecord::Base.connection
      tables = connection.tables - %w[schema_migrations ar_internal_metadata]

      connection.disable_referential_integrity do
        tables.each do |table|
          connection.execute("DELETE FROM #{connection.quote_table_name(table)}")
        end
      end
    end

    def transient_document_error?(error)
      error.message.include?('Node with given id does not belong to the document')
    end

    private

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end

  module SessionNavigation
    def visit(*args, **kwargs, &block)
      request_snapshot = ManyoSystemSpecSynchronization.snapshot
      result = super
      ManyoSystemSpecSynchronization.wait_for_request_cycle(after: request_snapshot, required: true)
      ManyoSystemSpecSynchronization.wait_for_document_ready
      result
    end
  end

  module ElementClick
    def click(*args, **kwargs, &block)
      request_snapshot = ManyoSystemSpecSynchronization.snapshot
      result = super
      if ManyoSystemSpecSynchronization.wait_for_request_cycle(after: request_snapshot)
        ManyoSystemSpecSynchronization.wait_for_document_ready
      end
      result
    end
  end

  module AlertAcceptance
    def accept
      request_snapshot = ManyoSystemSpecSynchronization.snapshot
      result = super
      ManyoSystemSpecSynchronization.wait_for_request_cycle(after: request_snapshot, required: true)
      ManyoSystemSpecSynchronization.wait_for_document_ready
      result
    end
  end
end

ActiveSupport::Notifications.subscribe('start_processing.action_controller') do
  ManyoSystemSpecSynchronization.request_started
end

ActiveSupport::Notifications.subscribe('process_action.action_controller') do
  ManyoSystemSpecSynchronization.request_finished
end

Capybara::Session.prepend(ManyoSystemSpecSynchronization::SessionNavigation)
Capybara::Node::Element.prepend(ManyoSystemSpecSynchronization::ElementClick)
Selenium::WebDriver::Alert.prepend(ManyoSystemSpecSynchronization::AlertAcceptance)
