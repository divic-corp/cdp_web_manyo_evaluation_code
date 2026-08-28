# frozen_string_literal: true

require 'active_support/notifications'
require 'capybara'
require 'selenium-webdriver'
require_relative '../support/system_spec_synchronization'

RSpec.describe ManyoSystemSpecSynchronization do
  describe '.wait_for_request_cycle' do
    it 'waits until a started request has completed and the request stream is quiet' do
      snapshot = described_class.snapshot
      worker = Thread.new do
        sleep 0.02
        described_class.request_started
        sleep 0.02
        described_class.request_finished
        sleep 0.03
        described_class.request_started
        sleep 0.02
        described_class.request_finished
      end

      expect(described_class.wait_for_request_cycle(after: snapshot, required: true, timeout: 1.0)).to eq true
      expect(worker).not_to be_alive
      worker.join
    end

    it 'returns without waiting for the full timeout when an element click triggers no request' do
      snapshot = described_class.snapshot
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      expect(described_class.wait_for_request_cycle(after: snapshot, timeout: 1.0)).to eq false
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
      expect(elapsed).to be < 0.8
    end
  end
end
