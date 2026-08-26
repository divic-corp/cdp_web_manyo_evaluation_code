# cdp_web_manyo_evaluation_code

「万葉」課題のStep 1〜5を、Ruby 4.0系／Ruby on Rails 8.1.3で評価するRSpecです。

## 対応バージョン

- 評価コード: `rails-8.1-v1.0.2`
- Ruby: 4.0系（4.0.0以上、4.1.0未満。標準環境は4.0.5）
- Ruby on Rails: 8.1.3
- PostgreSQL: 18.4
- RSpec Rails: 8.x
- Selenium WebDriver: 4.47.0以上

評価を再現できるよう、受講生向けCIと`bin/check`は評価コードのタグを固定して使用します。
`master`を直接参照しないでください。

互換性CIはRuby 4.0.5と4.0.6の両方で全Stepの評価コードを読み込みます。また、GitHub ActionsにインストールされたChromeを実際にheadlessで起動し、Selenium Managerが対応するdriverを解決できることと、複数回の画面遷移・DOM参照が安定して動くことを確認します。

## System Specの安定性

評価用System Specは、実行runnerの速度差に依存しないよう次の方針で実行します。

- Seleniumのpage load strategyは`normal`とし、通常のページ遷移ではdocumentのload完了を待つ
- Capybaraの同期matcherは最大5秒待機する
- CIではChromeを`--headless=new`、`--disable-dev-shm-usage`、`--no-sandbox`で起動する
- 固定` sleep`でタイミングを合わせない
- ChromeDriverはlegacy `webdrivers` gemではなくSelenium Managerで解決する

## 受講生による実行

受講生は`cdp_web_manyo_task`に用意されたコマンドを使用します。

```bash
bin/check step1
```

このリポジトリを受講生の`spec`ディレクトリへコピーする必要はありません。
各Stepのspecは、このリポジトリ自身の`rails_helper.rb`を相対パスで読み込みます。

## 評価コード開発時の確認

対象アプリを用意し、アプリの絶対パスを指定します。

```bash
MANYO_APP_ROOT=/path/to/cdp_web_manyo_task \
BUNDLE_GEMFILE=/path/to/cdp_web_manyo_evaluation_code/Gemfile.evaluation \
bundle exec rspec system/step1_spec.rb
```

`Gemfile.evaluation.lock`は対象アプリの`Gemfile.lock`をコピーしてから`bundle install`で作成します。
これにより、対象アプリの依存関係を維持したままRSpec Railsを追加できます。

## リリース手順

1. `cdp_web_manyo_task`側で対応するSelenium依存関係更新を先にマージする
2. GitHub ActionsのRails 8.1互換性チェックとChrome/Selenium smokeを成功させる
3. Step 1〜5の正解参照実装ですべての評価が成功することを確認する
4. 代表的な要件を壊した実装で、対応する評価が失敗することを確認する
5. 同一条件で3回実行し、結果が安定することを確認する
6. `VERSION`と同じannotated tagを作成してpushする

```bash
git tag -a rails-8.1-v1.0.2 -m "Manyo evaluator for Rails 8.1"
git push origin rails-8.1-v1.0.2
```

リリース済みタグは変更・付け替えを行いません。修正時はパッチバージョンを上げます。
