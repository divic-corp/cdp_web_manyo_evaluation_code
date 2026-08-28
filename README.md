# cdp_web_manyo_evaluation_code

「万葉」課題のStep 1〜5を、Ruby 4.0系／Ruby on Rails 8.1.3で評価するRSpecです。

## 対応バージョン

- 評価コード: `rails-8.1-v1.0.4`
- Ruby: 4.0系（4.0.0以上、4.1.0未満。標準環境は4.0.5）
- Ruby on Rails: 8.1.3
- PostgreSQL: 18.4
- RSpec Rails: 8.x
- Selenium WebDriver: 4.47.0以上

評価を再現できるよう、受講生向けCIと`bin/check`は評価コードのタグまたは固定SHAを使用します。
`master`を直接参照しないでください。

互換性CIはRuby 4.0.5と4.0.6の両方で全Stepの評価コードを読み込みます。また、GitHub ActionsにインストールされたChromeを実際にheadlessで起動し、Selenium Managerが対応するdriverを解決できることと、連続した画面遷移・DOM参照が安定して動くことを確認します。

## System Specの安定性

評価用System Specは、ブラウザ・Railsサーバ・RSpecプロセス間のタイミング差に評価結果が依存しないよう、次の方針で実行します。

- Seleniumのpage load strategyは`normal`とし、通常のページ遷移ではdocumentのload完了を待つ
- Capybaraの同期matcherは最大10秒待機する
- `visit`、要素クリック、確認ダイアログ承認後はRails controller requestの完了と短いquiet periodを確認してから次の評価へ進む
- Chromeがdocument置換中に返す一時的な`Node with given id does not belong to the document`系エラーは、Capybaraの同期時間内で再評価する
- browser-driven System Specではtransactional fixturesを使わず、各exampleの前後でtest DBを明示的にcleanにする
- seed、受講生RSpec、前のEvaluator exampleが残したレコードを次のexampleへ持ち越さない
- CIではChromeを`--headless=new`、`--disable-dev-shm-usage`、`--no-sandbox`で起動する
- 固定`sleep`でアプリケーションのタイミングを合わせない
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

1. `cdp_web_manyo_task`側のSelenium依存関係が4.47.0以上であることを確認する
2. GitHub ActionsのRails 8.1互換性チェック、同期helper regression test、Chrome/Selenium smokeを成功させる
3. Step 1〜5の正解参照実装ですべての評価が成功することを確認する
4. 代表的な要件を壊した実装で、対応する評価が失敗することを確認する
5. Step 4の正解参照実装を同一commit・同一条件で5回連続実行し、99 examplesの結果が5回とも一致することを確認する
6. 実際にflaky failureが報告された受講生実装でも、同一commitで複数回の結果が一致することを確認する
7. `VERSION`と同じannotated tagを作成してpushする

```bash
git tag -a rails-8.1-v1.0.4 -m "Manyo evaluator for Rails 8.1"
git push origin rails-8.1-v1.0.4
```

リリース済みタグは変更・付け替えを行いません。修正時はパッチバージョンを上げます。
