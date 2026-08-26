require_relative '../rails_helper'

RSpec.describe 'step2', type: :system do

  describe '開発要件' do
    let!(:task) { Task.create(title: 'task_title', content: 'task_content') }
    describe 'i18nを使って要件通りに文字やリンク、ボタンを国際化すること' do
      it 'グローバルナビゲーション' do
        visit root_path
        expect(page).to have_selector '#tasks-index', text: 'タスク一覧'
        expect(page).to have_selector '#new-task', text: 'タスクを登録する'
      end
      it 'タスク一覧画面' do
        visit tasks_path
        expect(page).to have_content 'タスク一覧ページ'
        expect(page).to have_selector '.show-task', text: '詳細'
        expect(page).to have_selector '.edit-task', text: '編集'
        expect(page).to have_selector '.destroy-task', text: '削除'
        find('.destroy-task').click
        expect(page.driver.browser.switch_to.alert.text).to eq '本当に削除してもよろしいですか？'
      end
      it 'タスク登録画面' do
        visit new_task_path
        expect(page).to have_content 'タスク登録ページ'
        expect(page).to have_selector 'label', text: 'タイトル'
        expect(page).to have_selector 'label', text: '内容'
        expect(page).to have_button '登録する'
        expect(page).to have_selector '#back', text: '戻る'
      end
      it 'タスク詳細画面' do
        visit task_path(task)
        expect(page).to have_content 'タスク詳細ページ'
        expect(page).to have_content 'タイトル'
        expect(page).to have_content '内容'
        expect(page).to have_selector '#edit-task', text: '編集'
        expect(page).to have_selector '#back', text: '戻る'
      end
      it 'タスク編集画面' do
        visit edit_task_path(task)
        expect(page).to have_content 'タスク編集ページ'
        expect(page).to have_content 'タイトル'
        expect(page).to have_content '内容'
        expect(page).to have_button '更新する'
        expect(page).to have_selector '#back', text: '戻る'
      end
      context 'バリデーションメッセージ' do
        it 'タスク登録画面でタイトルと内容が未入力の場合' do
          visit new_task_path
          find('input[name="task[title]"]').set('')
          find('textarea[name="task[content]"]').set('')
          find('#create-task').click
          expect(page).to have_content "タイトルを入力してください"
          expect(page).to have_content "内容を入力してください"
        end
        it 'タスク編集画面でタイトルと内容が未入力の場合' do
          visit edit_task_path(task)
          find('input[name="task[title]"]').set('')
          find('textarea[name="task[content]"]').set('')
          find('#update-task').click
          expect(page).to have_content "タイトルを入力してください"
          expect(page).to have_content "内容を入力してください"
        end
      end
      context 'フラッシュメッセージ' do
        it 'タスクの登録に成功した場合' do
          visit new_task_path
          fill_in 'タイトル', with: 'sample title'
          fill_in '内容', with: 'sample content'
          click_button '登録する'
          expect(page).to have_content "タスクを登録しました"
        end
        it 'タスクの更新に成功した場合' do
          visit edit_task_path(task)
          fill_in 'タイトル', with: 'update sample title'
          fill_in '内容', with: 'update sample content'
          click_button '更新する'
          expect(page).to have_content "タスクを更新しました"
        end
        it 'タスクを削除した場合' do
          visit tasks_path
          click_link '削除'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content "タスクを削除しました"
        end
      end
    end
    describe 'タスク一覧画面に表示させる作成日時を、あなたの住んでいる地域の時刻に設定すること' do
      it 'アプリケーションのタイムゾーンが明示的かつ有効に設定されていること' do
        config_files = Dir[Rails.root.join('config', '**', '*.rb')]
        timezone_configured = config_files.any? do |path|
          File.foreach(path).any? do |line|
            line.match?(/^\s*(?:Rails\.application\.)?config\.time_zone\s*=/)
          end
        end

        expect(timezone_configured).to be true
        expect(Time.find_zone(Rails.application.config.time_zone)).not_to be_nil
      end
    end
    describe 'データベースのデータを読み書きする際の時刻を、あなたの住んでいる地域の時刻に設定すること' do
      it 'タスクのcreated_atカラムがアプリケーションで設定したタイムゾーンで読み出されること' do
        task = Task.create!(title: 'task_title', content: 'task_content')
        created_at = task.reload.created_at

        expect(created_at).to be_a(ActiveSupport::TimeWithZone)
        expect(created_at.time_zone.name).to eq(Time.zone.name)
      end
    end
    describe 'seedデータを使って、50件分のタスクデータを投入できるようにすること' do
      it 'seedデータを使って、50件分のタスクデータを投入できるようにすること' do
        task_count_before_seed = Task.count

        load Rails.root.join('db/seeds.rb')

        expect(Task.count - task_count_before_seed).to be >= 50
      end
    end
  end

  describe '機能要件' do
    before do
      50.times do |n|
        Task.create(title: "task_title_#{n+1}", content: "task_content_#{n+1}")
      end
    end
    describe 'タスク一覧画面でタスクを作成日時の降順で表示させること' do
      it 'タスク一覧画面でタスクを作成日時の降順で表示させること' do
        visit tasks_path
        tasks = all('tbody tr')
        expect(tasks[0].text).to include('task_title_50')
        expect(tasks[1].text).to include('task_title_49')
        expect(tasks[2].text).to include('task_title_48')
        expect(tasks[3].text).to include('task_title_47')
        expect(tasks[4].text).to include('task_title_46')
        expect(tasks[5].text).to include('task_title_45')
        expect(tasks[6].text).to include('task_title_44')
        expect(tasks[7].text).to include('task_title_43')
        expect(tasks[8].text).to include('task_title_42')
        expect(tasks[9].text).to include('task_title_41')
      end
    end
    describe 'kaminariのgemを使って、タスク一覧画面にページネーションを実装し、1ページあたり10件のタスクを表示させること' do
      it 'タスク一覧画面にkaminariを適用させた際に作られるpaginationクラスが存在すること' do
        visit tasks_path
        expect(page).to have_css '.pagination'
      end
      it 'タスクに付与しているHTMLのクラス属性（show-task、edit-task、destroy-task）が10件分表示されること' do
        visit tasks_path
        expect(all('.show-task').count()).to eq 10
        expect(all('.edit-task').count()).to eq 10
        expect(all('.destroy-task').count()).to eq 10
      end
    end
  end
end
