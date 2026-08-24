require_relative '../rails_helper'

RSpec.describe 'step1', type: :system do

  let!(:task) { Task.create(title: 'task_title', content: 'task_content') }

  describe '画面遷移要件' do
    describe '1.要件通りにパスのプレフィックスが生成されていること' do
      it '要件通りにパスのプレフィックスが生成されていること' do
        visit tasks_path
        visit new_task_path
        visit task_path(task)
        visit edit_task_path(task)
      end
      it 'ルートにアクセスした際、「Tasks Index Page」の画面タイトルが表示されること' do
        visit root_path
        expect(page).to have_content 'Tasks Index Page'
      end
    end
  end

  describe '画面設計要件' do
    describe '2.要件通りに各画面に文字やリンク、ボタンを表示すること' do
      it 'グローバルナビゲーション' do
        visit root_path
        expect(page).to have_link 'Tasks Index'
        expect(page).to have_link 'New Task'
      end
      it 'タスク一覧画面' do
        visit tasks_path
        expect(page).to have_content 'Tasks Index Page'
        expect(page).to have_link 'Show'
        expect(page).to have_link 'Edit'
        expect(page).to have_link 'Destroy'
      end
      it 'タスク登録画面' do
        visit new_task_path
        expect(page).to have_content 'New Task Page'
        expect(page).to have_selector 'label', text: 'Title'
        expect(page).to have_selector 'label', text: 'Content'
        expect(page).to have_button 'Create Task'
        expect(page).to have_link 'Back'
      end
      it 'タスク詳細画面' do
        visit task_path(task)
        expect(page).to have_content 'Show Task Page'
        expect(page).to have_link 'Edit'
        expect(page).to have_link 'Back'
      end
      it 'タスク編集画面' do
        visit edit_task_path(task)
        expect(page).to have_content 'Edit Task Page'
        expect(page).to have_selector 'label', text: 'Title'
        expect(page).to have_selector 'label', text: 'Content'
        expect(page).to have_button 'Update Task'
        expect(page).to have_link 'Back'
      end
    end
    describe '3.要件通りにHTMLのid属性とclass属性が付与されていること' do
      it 'グローバルナビゲーション' do
        visit root_path
        expect(page).to have_selector '#tasks-index', text: 'Tasks Index'
        expect(page).to have_selector '#new-task', text: 'New Task'
      end
      it '一覧画面' do
        visit tasks_path
        expect(page).to have_selector '.show-task', text: 'Show'
        expect(page).to have_selector '.edit-task', text: 'Edit'
        expect(page).to have_selector '.destroy-task', text: 'Destroy'
      end
      it '登録画面' do
        visit new_task_path
        expect(page).to have_selector '#create-task'
        expect(page).to have_selector '#back', text: 'Back'
      end
      it '詳細画面' do
        visit task_path(task)
        expect(page).to have_selector '#edit-task', text: 'Edit'
        expect(page).to have_selector '#back', text: 'Back'
      end
      it '編集画面' do
        visit edit_task_path(task)
        expect(page).to have_selector '#update-task'
        expect(page).to have_selector '#back', text: 'Back'
      end
    end
    describe '4.一覧画面に登録したタスクのタイトルと説明、作成日時を一覧で表示すること' do
      it '一覧画面に登録したタスクのタイトルと説明、作成日時を一覧で表示すること' do
        visit tasks_path
        expect(page).to have_content task.title
        expect(page).to have_content task.content
        expect(page).to have_content task.created_at
      end
    end
    describe '5.詳細画面にそのタスクのタイトルと説明、作成日時を表示すること' do
      it '詳細画面にそのタスクのタイトルと説明、作成日時を表示すること' do
        visit task_path(task)
        expect(page).to have_content task.title
        expect(page).to have_content task.content
        expect(page).to have_content task.created_at
      end
    end
  end

  describe '画面遷移要件' do
    describe '6.画面遷移図通りに遷移させること' do
      it 'グローバルナビゲーションのリンクを要件通りに遷移させること' do
        visit tasks_path
        click_link 'New Task'
        expect(page).to have_content 'New Task Page'
        click_link 'Tasks Index'
        expect(page).to have_content 'Tasks Index Page'
      end
      it '一覧画面から登録に遷移した際、ページタイトルに「New Task Page」が表示される' do
        visit tasks_path
        find('#new-task').click
        expect(page).to have_content 'New Task Page'
      end
      it 'タスクを登録した場合、ページタイトルに「Tasks Index Page」が表示される' do
        visit new_task_path
        fill_in 'Title', with: 'task_title'
        fill_in 'Content', with: 'task_content'
        find('#create-task').click
        expect(page).to have_content 'Tasks Index Page'
      end
      it '「Show」をクリックした場合、ページタイトルに「Show Task Page」が表示される' do
        visit tasks_path
        find('.show-task').click
        expect(page).to have_content 'Show Task Page'
      end
      it '「Edit」をクリックした場合、ページタイトルに「Edit Task Page」が表示される' do
        visit tasks_path
        find('.edit-task').click
        expect(page).to have_content 'Edit Task Page'
      end
      it '「Update Task」をクリックした場合、ページタイトルに「Show Task Page」が表示される' do
        visit edit_task_path(task)
        find('#update-task').click
        expect(page).to have_content 'Show Task Page'
      end
      it '「Destroy」をクリックした場合、ページタイトルに「Tasks Index Page」が表示される' do
        visit tasks_path
        find('.destroy-task').click
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content 'Tasks Index Page'
      end
      it '登録画面の「Back」をクリックした場合、ページタイトルに「Tasks Index Page」が表示される' do
        visit new_task_path
        find('#back').click
        expect(page).to have_content 'Tasks Index Page'
      end
      it '詳細画面の「Back」をクリックした場合、ページタイトルに「Tasks Index Page」が表示される' do
        visit task_path(task)
        find('#back').click
        expect(page).to have_content 'Tasks Index Page'
      end
      it '編集画面の「Back」をクリックした場合、ページタイトルに「Tasks Index Page」が表示される' do
        visit edit_task_path(task)
        find('#back').click
        expect(page).to have_content 'Tasks Index Page'
      end
      it 'タスクの登録に失敗した場合、ページタイトルに「New Task Page」が表示される' do
        visit new_task_path
        fill_in 'Title', with: ''
        fill_in 'Content', with: ''
        find('#create-task').click
        expect(page).to have_content 'New Task Page'
      end
      it 'タスクの編集に失敗した場合、ページタイトルに「Edit Task Page」が表示される' do
        visit edit_task_path(task)
        fill_in 'Title', with: ''
        fill_in 'Content', with: ''
        find('#update-task').click
        expect(page).to have_content 'Edit Task Page'
      end
    end
  end

  describe '機能要件' do
    describe '7.タスクを削除するリンクをクリックした際、確認ダイアログに「Are you sure?」という文字を表示させること' do
      it 'タスクを削除するリンクをクリックした際、確認ダイアログに「Are you sure?」という文字を表示させること' do
        visit tasks_path
        click_link 'Destroy'
        expect(page.driver.browser.switch_to.alert.text).to eq 'Are you sure?'
      end
    end
    describe '8.タスクの登録や編集でバリデーションに失敗した場合、要件通りにバリデーションメッセージを表示させること' do
      context 'タスク登録画面' do
        it "タイトルが未入力の場合、「Title can't be blank」というバリデーションメッセージが表示させる" do
          visit new_task_path
          fill_in 'Title', with: ''
          fill_in 'Content', with: 'sample content'
          find('#create-task').click
          expect(page).to have_content "Title can't be blank"
        end
        it "内容が未入力の場合、「Content can't be blank」というバリデーションメッセージが表示させる" do
          visit new_task_path
          fill_in 'Title', with: 'sample title'
          fill_in 'Content', with: ''
          find('#create-task').click
          expect(page).to have_content "Content can't be blank"
        end
        it "タイトルと内容が未入力の場合、「Title can't be blank」と「Content can't be blank」というバリデーションメッセージが表示させる" do
          visit new_task_path
          fill_in 'Title', with: ''
          fill_in 'Content', with: ''
          find('#create-task').click
          expect(page).to have_content "Title can't be blank"
          expect(page).to have_content "Content can't be blank"
        end
      end
      context 'タスク編集画面' do
        it "タイトルが未入力の場合、「Title can't be blank」というバリデーションメッセージが表示させる" do
          visit edit_task_path(task)
          fill_in 'Title', with: ''
          fill_in 'Content', with: task.content
          find('#update-task').click
          expect(page).to have_content "Title can't be blank"
        end
        it "内容が未入力の場合、「Content can't be blank」というバリデーションメッセージが表示させる" do
          visit edit_task_path(task)
          fill_in 'Title', with: task.title
          fill_in 'Content', with: ''
          find('#update-task').click
          expect(page).to have_content "Content can't be blank"
        end
        it "タイトルと内容が未入力の場合、「Title can't be blank」と「Content can't be blank」というバリデーションメッセージが表示させる" do
          visit edit_task_path(task)
          fill_in 'Title', with: ''
          fill_in 'Content', with: ''
          find('#update-task').click
          expect(page).to have_content "Title can't be blank"
          expect(page).to have_content "Content can't be blank"
        end
      end
    end
    describe '9.要件通りにフラッシュメッセージを表示させること' do
      context 'タスクの登録に成功した場合' do
        it '「Task was successfully created.」というフラッシュメッセージを表示させること' do
          visit new_task_path
          fill_in 'Title', with: 'sample title'
          fill_in 'Content', with: 'sample content'
          find('#create-task').click
          expect(page).to have_content "Task was successfully created."
        end
      end
      context 'タスクの更新に成功した場合' do
        it '「Task was successfully updated.」というフラッシュメッセージを表示させること' do
          visit edit_task_path(task)
          fill_in 'Title', with: 'update sample title'
          fill_in 'Content', with: 'update sample content'
          find('#update-task').click
          expect(page).to have_content "Task was successfully updated."
        end
      end
      context 'タスクを削除した場合' do
        it '「Task was successfully destroyed.」というフラッシュメッセージを表示させること' do
          visit tasks_path
          find('.destroy-task').click
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content "Task was successfully destroyed."
        end
      end
    end
  end
end
