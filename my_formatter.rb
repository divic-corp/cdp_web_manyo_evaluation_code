class MyFormatter
  RSpec::Core::Formatters.register(
    self,
    :start,
    :example_group_started,
    :example_passed,
    :example_failed,
    :example_pending,
    :dump_summary
  )

  def initialize(output)
    @output = output
  end

  def start(_notification)
    @output << "# 万葉課題 評価結果\n\n"
  end

  def example_passed(notification)
    @output << "- ✅ #{notification.example.description}\n"
  end

  def example_group_started(notification)
    depth = notification.group.parent_groups.length
    return if depth > 3

    @output << "\n#{'#' * [depth + 1, 4].min} #{notification.group.description}\n\n"
  end

  def example_failed(notification)
    @output << "- [ ] ❌ #{notification.example.description}\n"
  end

  def example_pending(notification)
    @output << "- [ ] ⚠️ #{notification.example.description}（保留）\n"
  end

  def dump_summary(notification)
    @output << "\n## 集計\n\n"
    @output << "- 成功: #{notification.example_count - notification.failure_count - notification.pending_count}\n"
    @output << "- 失敗: #{notification.failure_count}\n"
    @output << "- 保留: #{notification.pending_count}\n"

    return unless notification.example_count.zero?

    @output << <<~MESSAGE

      ## 評価を開始できませんでした

      評価コードの読み込み、依存関係、データベース準備、または
      アプリケーション起動に失敗した可能性があります。
      受講生のコードに構文エラーがあるとは限らないため、GitHub Actionsのログを確認してください。
    MESSAGE
    if notification.respond_to?(:errors_outside_of_examples_count)
      @output << "- テスト例外で発生したエラー: #{notification.errors_outside_of_examples_count}\n"
    end
  end
end
