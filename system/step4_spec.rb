require_relative '../rails_helper'

RSpec.describe 'step4', type: :system do

  let!(:user) { User.create(name: 'user_name', email: 'user@email.com', password: 'password', admin: false) }
  let!(:admin) { User.create(name: 'admin_name', email: 'admin@email.com', password: 'password', admin: true) }

  describe '開発要件' do
    it 'Deviseを使用せずに認証を実装すること' do
      expect(Gem.loaded_specs).not_to have_key('devise')
    end
  end

  describe '画面遷移要件' do
    describe '1.要件通りにパスのプレフィックスが使用できること' do
      context 'ログアウト中の場合' do
        it '要件通りにパスのプレフィックスが使用できること' do
          visit new_session_path
          visit new_user_path
        end
      end
      context '一般ユーザでログイン中の場合' do
        before do
          visit root_path
          find('#sign-in').click
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          find('#create-session').click
        end
        it '要件通りにパスのプレフィックスが使用できること' do
          visit user_path(user)
          visit edit_user_path(user)
        end
      end
      context '管理者でログイン中の場合' do
        before do
          visit root_path
          find('#sign-in').click
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          find('#create-session').click
        end
        it '要件通りにパスのプレフィックスが使用できること' do
          visit admin_users_path
          visit new_admin_user_path
          visit admin_user_path(user)
          visit edit_admin_user_path(user)
        end
      end
    end
  end

  describe '画面設計要件' do
    describe '2.要件通りにHTMLのid属性やclass属性が付与されていること' do
      context 'ログアウト中の場合' do
        it 'グローバルナビゲーション' do
          visit root_path
          expect(page).to have_css '#sign-up'
          expect(page).to have_css '#sign-in'
          expect(page).not_to have_css '#account-setting'
          expect(page).not_to have_css '#sign-out'
          expect(page).not_to have_css '#users-index'
          expect(page).not_to have_css '#add-user'
        end
        it 'ログイン画面' do
          visit root_path
          find('#sign-in').click
          expect(page).to have_css '#create-session'
        end
        it 'アカウント登録画面' do
          visit root_path
          find('#sign-up').click
          expect(page).to have_css '#create-user'
        end
      end
      context '一般ユーザでログイン中の場合' do
        before do
          visit root_path
          find('#sign-in').click
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          find('#create-session').click
        end
        it 'グローバルナビゲーション' do
          expect(page).to have_css '#account-setting'
          expect(page).to have_css '#sign-out'
          expect(page).not_to have_css '#users-index'
          expect(page).not_to have_css '#add-user'
          expect(page).not_to have_css '#sign-up'
          expect(page).not_to have_css '#sign-in'
        end
        it 'アカウント詳細画面' do
          find('#account-setting').click
          expect(page).to have_css '#edit-user'
        end
        it 'アカウント編集画面' do
          find('#account-setting').click
          find('#edit-user').click
          expect(page).to have_css '#update-user'
          expect(page).to have_css '#back'
        end
      end
      context '管理者でログイン中の場合' do
        before do
          visit root_path
          find('#sign-in').click
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          find('#create-session').click
        end
        it 'グローバルナビゲーション' do
          expect(page).to have_css '#account-setting'
          expect(page).to have_css '#sign-out'
          expect(page).to have_css '#users-index'
          expect(page).to have_css '#add-user'
          expect(page).not_to have_css '#sign-up'
          expect(page).not_to have_css '#sign-in'
        end
        it 'ユーザ一覧画面' do
          find('#users-index').click
          expect(page).to have_css '.show-user'
          expect(page).to have_css '.edit-user'
          expect(page).to have_css '.destroy-user'
        end
        it 'ユーザ登録画面（管理者用）' do
          find('#users-index').click
          find("#add-user").click
          expect(page).to have_css '#create-user'
        end
        it 'ユーザ編集画面（管理者用）' do
          find('#users-index').click
          all(".edit-user")[0].click
          expect(page).to have_css '#update-user'
          expect(page).to have_css '#back'
        end
      end
    end
  end

  describe '画面設計要件' do
    describe '3.要件通りに各画面に文字やリンク、ボタンを表示すること' do
      context 'ログアウト中の場合' do
        it 'グローバルナビゲーション' do
          visit root_path
          expect(page).to have_link 'アカウント登録'
          expect(page).to have_link 'ログイン'
        end
        it 'ログイン画面' do
          visit root_path
          click_link 'ログイン'
          expect(page).to have_content 'ログインページ'
          expect(page).to have_selector 'label', text: 'メールアドレス'
          expect(page).to have_selector 'label', text: 'パスワード'
          expect(page).to have_button 'ログイン'
        end
        it 'アカウント登録画面' do
          visit root_path
          click_link 'アカウント登録'
          expect(page).to have_content 'アカウント登録ページ'
          expect(page).to have_selector 'label', text: '名前'
          expect(page).to have_selector 'label', text: 'メールアドレス'
          expect(page).to have_selector 'label', text: 'パスワード'
          expect(page).to have_selector 'label', text: 'パスワード（確認）'
          expect(page).to have_button '登録する'
        end
      end
      context '一般ユーザでログイン中の場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          click_button 'ログイン'
        end
        it 'グローバルナビゲーション' do
          expect(page).to have_link 'タスク一覧'
          expect(page).to have_link 'タスクを登録する'
          expect(page).to have_link 'アカウント'
          expect(page).to have_link 'ログアウト'
        end
        it 'アカウント詳細画面' do
          click_link 'アカウント'
          expect(page).to have_content 'アカウント詳細ページ'
          expect(page).to have_content '名前'
          expect(page).to have_content 'メールアドレス'
          expect(page).to have_link '編集'
        end
        it 'アカウント編集画面' do
          click_link 'アカウント'
          click_link '編集'
          expect(page).to have_content 'アカウント編集ページ'
          expect(page).to have_selector 'label', text: '名前'
          expect(page).to have_selector 'label', text: 'メールアドレス'
          expect(page).to have_selector 'label', text: 'パスワード'
          expect(page).to have_selector 'label', text: 'パスワード（確認）'
          expect(page).to have_button '更新する'
          expect(page).to have_link '戻る'
        end
      end
      context '管理者ユーザでログイン中の場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          click_button 'ログイン'
        end
        it 'グローバルナビゲーション' do
          expect(page).to have_link 'ユーザ一覧'
          expect(page).to have_link 'ユーザを登録する'
          expect(page).to have_link 'タスク一覧'
          expect(page).to have_link 'タスクを登録する'
          expect(page).to have_link 'アカウント'
          expect(page).to have_link 'ログアウト'
        end
        it 'ユーザ一覧画面' do
          click_link 'ユーザ一覧'
          expect(page).to have_content 'ユーザ一覧ページ'
          expect(page).to have_selector 'thead', text: '名前'
          expect(page).to have_selector 'thead', text: 'メールアドレス'
          expect(page).to have_selector 'thead', text: '管理者権限'
          expect(page).to have_selector 'thead', text: 'タスク数'
          expect(page).to have_link '詳細'
          expect(page).to have_link '編集'
          expect(page).to have_link '削除'
        end
        it 'ユーザ登録画面' do
          click_link 'ユーザを登録する'
          expect(page).to have_content 'ユーザ登録ページ'
          expect(page).to have_selector 'label', text: '名前'
          expect(page).to have_selector 'label', text: 'メールアドレス'
          expect(page).to have_selector 'label', text: 'パスワード'
          expect(page).to have_selector 'label', text: 'パスワード（確認）'
          expect(page).to have_selector 'label', text: '管理者権限'
          expect(page).to have_button '登録する'
        end
        it 'ユーザ詳細画面' do
          click_link 'ユーザ一覧'
          all(".show-user")[0].click
          expect(page).to have_content 'ユーザ詳細ページ'
          expect(page).to have_content '名前'
          expect(page).to have_content 'メールアドレス'
          expect(page).to have_content '管理者権限'
          expect(page).to have_selector 'thead', text: 'タイトル'
          expect(page).to have_selector 'thead', text: '内容'
          expect(page).to have_selector 'thead', text: '作成日時'
          expect(page).to have_selector 'thead', text: '終了期限'
          expect(page).to have_selector 'thead', text: '優先度'
          expect(page).to have_selector 'thead', text: 'ステータス'
        end
        it 'ユーザ編集画面' do
          click_link 'ユーザ一覧'
          all(".edit-user")[0].click
          expect(page).to have_content 'ユーザ編集ページ'
          expect(page).to have_selector 'label', text: '名前'
          expect(page).to have_selector 'label', text: 'メールアドレス'
          expect(page).to have_selector 'label', text: 'パスワード'
          expect(page).to have_selector 'label', text: 'パスワード（確認）'
          expect(page).to have_selector 'label', text: '管理者権限'
          expect(page).to have_button '更新する'
          expect(page).to have_link '戻る'
        end
      end
    end

    describe '4.ユーザ一覧画面には、各ユーザが作成しているタスクの数を表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it 'ユーザ一覧画面には、各ユーザが作成しているタスクの数を表示させること' do
        10.times do
          Task.create(title: 'task_title', content: 'task_content', deadline_on: Date.today, priority: 0, status: 0, user_id: user.id)
        end
        5.times do
          Task.create(title: 'task_title', content: 'task_content', deadline_on: Date.today, priority: 0, status: 0, user_id: admin.id)
        end
        visit root_path
        click_link 'ユーザ一覧'
        expect(page).to have_content '10'
        expect(page).to have_content '5'
      end
    end

    describe '5.ユーザ一覧画面の管理者権限の項目で管理者権限がある場合は「あり」、ない場合は「なし」を表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it 'ユーザが管理者のみの場合、ユーザ一覧に「あり」が表示させる' do
        User.destroy_by(name: 'user_name')
        click_link 'ユーザ一覧'
        expect(page).to have_content 'あり'
        expect(page).not_to have_content 'なし'
      end
      it '一般ユーザと管理者が存在する場合、ユーザ一覧に「あり」と「なし」が表示させる' do
        click_link 'ユーザ一覧'
        expect(page).to have_content 'あり'
        expect(page).to have_content 'なし'
      end
    end

    describe '6.ユーザ詳細画面の管理者権限の項目で管理者権限がある場合は「あり」、ない場合は「なし」を表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it '管理者の場合、「あり」が表示させる' do
        click_link 'ユーザ一覧'
        click_link '詳細', href: admin_user_path(admin)
        expect(page).to have_content 'あり'
      end
      it '一般ユーザの場合、「なし」が表示させる' do
        click_link 'ユーザ一覧'
        click_link '詳細', href: admin_user_path(user)
        expect(page).to have_content 'なし'
      end
    end

    describe '7.ユーザ詳細画面にそのユーザが作成したタスクのタイトル、内容、終了期限、優先度、ステータスを一覧で表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it '登録したタスク情報が一覧で表示させること' do
        10.times do |n|
          Task.create(title: "task_title_#{n}", content: "task_content_#{n}", deadline_on: Date.today, priority: n%3, status: n%3, user_id: user.id)
        end
        click_link 'ユーザ一覧'
        click_link '詳細', href: admin_user_path(user)
        10.times do |n|
          expect(page).to have_content "task_title_#{n}"
        end
        10.times do |n|
          expect(page).to have_content "task_content_#{n}"
        end
        expect(page).to have_content '高'
        expect(page).to have_content '中'
        expect(page).to have_content '低'
        expect(page).to have_content '未着手'
        expect(page).to have_content '着手中'
        expect(page).to have_content '完了'
      end
    end
  end

  describe '8.画面遷移要件' do
    describe '画面遷移図通りに遷移させること' do
      context 'ログアウト中の場合' do
        it 'グローバルナビゲーションのリンクを要件通りに遷移させること' do
          visit root_path
          click_link 'ログイン'
          expect(page).to have_content 'ログインページ'
          click_link 'アカウント登録'
          expect(page).to have_content 'アカウント登録ページ'
        end
        it 'アカウント登録に成功した場合、ページタイトルに「タスク一覧ページ」が表示される' do
          visit new_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('new_password')
          find('input[name="user[password_confirmation]"]').set('new_password')
          click_button '登録する'
          expect(page).to have_content 'タスク一覧ページ'
        end
        it 'アカウント登録に失敗した場合、ページタイトルに「アカウント登録ページ」が表示される' do
          visit new_user_path
          find('input[name="user[name]"]').set('')
          find('input[name="user[email]"]').set('')
          find('input[name="user[password]"]').set('')
          find('input[name="user[password_confirmation]"]').set('')
          click_button '登録する'
          expect(page).to have_content 'アカウント登録ページ'
        end
        it 'ログインに成功した場合、ページタイトルに「タスク一覧ページ」が表示される' do
          visit new_session_path
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          click_button 'ログイン'
          expect(page).to have_content 'タスク一覧ページ'
        end
        it 'ログインに失敗した場合、ページタイトルに「ログインページ」が表示される' do
          visit new_session_path
          find('input[name="session[email]"]').set('failed@email.com')
          find('input[name="session[password]"]').set('failed_password')
          click_button 'ログイン'
          expect(page).to have_content 'ログインページ'
        end
      end
      context '一般ユーザでログイン中の場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          click_button 'ログイン'
        end
        it 'グローバルナビゲーションのリンクを要件通りに遷移させること' do
          click_link 'アカウント'
          expect(page).to have_content 'アカウント詳細ページ'
          click_link 'ログアウト'
          expect(page).to have_content 'ログインページ'
        end
        it 'アカウント詳細画面の「編集」をクリックした場合、ページタイトルに「アカウント編集ページ」が表示される' do
          visit user_path(user)
          click_link '編集'
          expect(page).to have_content 'アカウント編集ページ'
        end
        it 'アカウントの編集に成功した場合、ページタイトルに「アカウント詳細ページ」が表示される' do
          visit edit_user_path(user)
          find('input[name="user[name]"]').set('edit_user_name')
          find('input[name="user[email]"]').set('edit_user@email.com')
          find('input[name="user[password]"]').set('edit_password')
          find('input[name="user[password_confirmation]"]').set('edit_password')
          click_button '更新する'
          expect(page).to have_content 'アカウント詳細ページ'
        end
        it 'アカウントの編集に失敗した場合、ページタイトルに「アカウント編集ページ」が表示される' do
          visit edit_user_path(user)
          find('input[name="user[name]"]').set('')
          find('input[name="user[email]"]').set('')
          find('input[name="user[password]"]').set('')
          find('input[name="user[password_confirmation]"]').set('')
          click_button '更新する'
          expect(page).to have_content 'アカウント編集ページ'
        end
        it 'アカウント編集画面の「戻る」をクリックした場合、ページタイトルに「アカウント詳細ページ」が表示される' do
          visit edit_user_path(user)
          click_link '戻る'
          expect(page).to have_content 'アカウント詳細ページ'
        end
      end
      context '管理者でログイン中の場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          click_button 'ログイン'
        end
        it 'グローバルナビゲーションのリンクを要件通りに遷移させること' do
          click_link 'アカウント'
          expect(page).to have_content 'アカウント詳細ページ'
          click_link 'ログアウト'
          expect(page).to have_content 'ログインページ'
        end
        it 'ユーザ一覧画面の「詳細」をクリックした場合、ページタイトルに「ユーザ詳細ページ」が表示される' do
          visit admin_users_path
          click_link '詳細', href: admin_user_path(user)
          expect(page).to have_content 'ユーザ詳細ページ'
        end
        it 'ユーザ一覧画面の「編集」をクリックした場合、ページタイトルに「ユーザ編集ページ」が表示される' do
          visit admin_users_path
          click_link '編集', href: edit_admin_user_path(user)
          expect(page).to have_content 'ユーザ編集ページ'
        end
        it 'ユーザ一覧画面の「削除」をクリックした場合、ページタイトルに「ユーザ一覧ページ」が表示される' do
          visit admin_users_path
          click_link '削除', href: admin_user_path(user)
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'ユーザ一覧ページ'
        end
        it 'ユーザ編集画面の「戻る」をクリックした場合、ページタイトルに「ユーザ一覧ページ」が表示される' do
          visit edit_admin_user_path(user)
          click_link '戻る'
          expect(page).to have_content 'ユーザ一覧ページ'
        end
        it 'ユーザの登録に成功した場合、ページタイトルに「ユーザ一覧ページ」が表示される' do
          visit new_admin_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('new_password')
          find('input[name="user[password_confirmation]"]').set('new_password')
          click_button '登録する'
          expect(page).to have_content 'ユーザ一覧ページ'
        end
        it 'ユーザの登録に失敗した場合、ページタイトルに「ユーザ登録ページ」が表示される' do
          visit new_admin_user_path
          find('input[name="user[name]"]').set('')
          find('input[name="user[email]"]').set('')
          find('input[name="user[password]"]').set('')
          find('input[name="user[password_confirmation]"]').set('')
          click_button '登録する'
          expect(page).to have_content 'ユーザ登録ページ'
        end
        it 'ユーザの編集に成功した場合、ページタイトルに「ユーザ一覧ページ」が表示される' do
          visit edit_admin_user_path(user)
          find('input[name="user[name]"]').set('edit_user_name')
          find('input[name="user[email]"]').set('edit_user@email.com')
          find('input[name="user[password]"]').set('edit_password')
          find('input[name="user[password_confirmation]"]').set('edit_password')
          click_button '更新する'
          expect(page).to have_content 'ユーザ一覧ページ'
        end
        it 'ユーザの編集に失敗した場合、ページタイトルに「ユーザ編集ページ」が表示される' do
          visit edit_admin_user_path(user)
          find('input[name="user[name]"]').set('')
          find('input[name="user[email]"]').set('')
          find('input[name="user[password]"]').set('')
          find('input[name="user[password_confirmation]"]').set('')
          click_button '更新する'
          expect(page).to have_content 'ユーザ編集ページ'
        end
      end
    end
  end

  describe '機能要件' do
    describe '9.ユーザを削除するリンクをクリックした際、確認ダイアログに「本当に削除してもよろしいですか？」という文字を表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it 'ユーザを削除するリンクをクリックした際、確認ダイアログに"本当に削除してもよろしいですか？"という文字を表示させること' do
        visit admin_users_path
        click_link '削除', href: admin_user_path(user)
        expect(page.driver.browser.switch_to.alert.text).to eq '本当に削除してもよろしいですか？'
      end
    end

    describe '10.アカウントの登録や編集、ユーザの登録や編集でバリデーションに失敗した場合、要件で示した条件通りにバリデーションメッセージを表示させること' do
      context 'アカウント登録画面' do
        it 'すべてフォームが未入力の場合のバリデーションメッセージ' do
          visit new_user_path
          find('input[name="user[name]"]').set('')
          find('input[name="user[email]"]').set('')
          find('input[name="user[password]"]').set('')
          find('input[name="user[password_confirmation]"]').set('')
          click_button '登録する'
          expect(page).to have_content '名前を入力してください'
          expect(page).to have_content 'メールアドレスを入力してください'
          expect(page).to have_content 'パスワードを入力してください'
        end
        it 'すでに使用されているメールアドレスを入力した場合のバリデーションメッセージ' do
          visit new_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set(user.email)
          find('input[name="user[password]"]').set('password')
          find('input[name="user[password_confirmation]"]').set('password')
          click_button '登録する'
          expect(page).to have_content 'メールアドレスはすでに使用されています'
        end
        it 'パスワードが6文字未満の場合のバリデーションメッセージ' do
          visit new_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('passw')
          find('input[name="user[password_confirmation]"]').set('passw')
          click_button '登録する'
          expect(page).to have_content 'パスワードは6文字以上で入力してください'
        end
        it 'パスワードとパスワード（確認）が一致しない場合のバリデーションメッセージ' do
          visit new_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('password')
          find('input[name="user[password_confirmation]"]').set('passwordd')
          click_button '登録する'
          expect(page).to have_content 'パスワード（確認）とパスワードの入力が一致しません'
        end
      end
      context 'アカウント編集画面' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          click_button 'ログイン'
        end
        it 'すべてフォームが未入力の場合のバリデーションメッセージ' do
          visit edit_user_path(user)
          find('input[name="user[name]"]').set('')
          find('input[name="user[email]"]').set('')
          find('input[name="user[password]"]').set('')
          find('input[name="user[password_confirmation]"]').set('')
          click_button '更新する'
          expect(page).to have_content '名前を入力してください'
          expect(page).to have_content 'メールアドレスを入力してください'
          expect(page).to have_content 'パスワードは6文字以上で入力してください'
        end
        it 'すでに使用されているメールアドレスを入力した場合のバリデーションメッセージ' do
          visit edit_user_path(user)
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set(admin.email)
          find('input[name="user[password]"]').set('password')
          find('input[name="user[password_confirmation]"]').set('password')
          click_button '更新する'
          expect(page).to have_content 'メールアドレスはすでに使用されています'
        end
        it 'パスワードが6文字未満の場合のバリデーションメッセージ' do
          visit edit_user_path(user)
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('passw')
          find('input[name="user[password_confirmation]"]').set('passw')
          click_button '更新する'
          expect(page).to have_content 'パスワードは6文字以上で入力してください'
        end
        it 'パスワードとパスワード（確認）が一致しない場合のバリデーションメッセージ' do
          visit edit_user_path(user)
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('password')
          find('input[name="user[password_confirmation]"]').set('passwordd')
          click_button '更新する'
          expect(page).to have_content 'パスワード（確認）とパスワードの入力が一致しません'
        end
      end
      context 'ユーザ登録画面' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          click_button 'ログイン'
        end
        it 'すべてフォームが未入力の場合のバリデーションメッセージ' do
          visit new_admin_user_path
          find('input[name="user[name]"]').set('')
          find('input[name="user[email]"]').set('')
          find('input[name="user[password]"]').set('')
          find('input[name="user[password_confirmation]"]').set('')
          click_button '登録する'
          expect(page).to have_content '名前を入力してください'
          expect(page).to have_content 'メールアドレスを入力してください'
          expect(page).to have_content 'パスワードを入力してください'
        end
        it 'すでに使用されているメールアドレスを入力した場合のバリデーションメッセージ' do
          visit new_admin_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set(user.email)
          find('input[name="user[password]"]').set('password')
          find('input[name="user[password_confirmation]"]').set('password')
          click_button '登録する'
          expect(page).to have_content 'メールアドレスはすでに使用されています'
        end
        it 'パスワードが6文字未満の場合のバリデーションメッセージ' do
          visit new_admin_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('passw')
          find('input[name="user[password_confirmation]"]').set('passw')
          click_button '登録する'
          expect(page).to have_content 'パスワードは6文字以上で入力してください'
        end
        it 'パスワードとパスワード（確認）が一致しない場合のバリデーションメッセージ' do
          visit new_admin_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('password')
          find('input[name="user[password_confirmation]"]').set('passwordd')
          click_button '登録する'
          expect(page).to have_content 'パスワード（確認）とパスワードの入力が一致しません'
        end
      end
      context 'ユーザ編集画面' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          click_button 'ログイン'
        end
        it 'すべてフォームが未入力の場合のバリデーションメッセージ' do
          visit edit_admin_user_path(user)
          find('input[name="user[name]"]').set('')
          find('input[name="user[email]"]').set('')
          find('input[name="user[password]"]').set('')
          find('input[name="user[password_confirmation]"]').set('')
          click_button '更新する'
          expect(page).to have_content '名前を入力してください'
          expect(page).to have_content 'メールアドレスを入力してください'
          expect(page).to have_content 'パスワードは6文字以上で入力してください'
        end
        it 'すでに使用されているメールアドレスを入力した場合のバリデーションメッセージ' do
          visit edit_admin_user_path(user)
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set(admin.email)
          find('input[name="user[password]"]').set('password')
          find('input[name="user[password_confirmation]"]').set('password')
          click_button '更新する'
          expect(page).to have_content 'メールアドレスはすでに使用されています'
        end
        it 'パスワードが6文字未満の場合のバリデーションメッセージ' do
          visit edit_admin_user_path(user)
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('passw')
          find('input[name="user[password_confirmation]"]').set('passw')
          click_button '更新する'
          expect(page).to have_content 'パスワードは6文字以上で入力してください'
        end
        it 'パスワードとパスワード（確認）が一致しない場合のバリデーションメッセージ' do
          visit edit_admin_user_path(user)
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('password')
          find('input[name="user[password_confirmation]"]').set('passwordd')
          click_button '更新する'
          expect(page).to have_content 'パスワード（確認）とパスワードの入力が一致しません'
        end
      end
    end

    describe '11.要件で示した条件通りにフラッシュメッセージを表示させること' do
      context 'アカウントの登録に成功した場合' do
        it '「アカウントを登録しました」というフラッシュメッセージを表示させること' do
          visit new_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('new_password')
          find('input[name="user[password_confirmation]"]').set('new_password')
          click_button '登録する'
          expect(page).to have_content 'アカウントを登録しました'
        end
      end
      context 'アカウントの更新に成功した場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          click_button 'ログイン'
        end
        it '「アカウントを更新しました」というフラッシュメッセージを表示させること' do
          visit edit_user_path(user)
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('new_password')
          find('input[name="user[password_confirmation]"]').set('new_password')
          click_button '更新する'
          expect(page).to have_content 'アカウントを更新しました'
        end
      end
      context 'ログインに成功した場合' do
        it '「ログインしました」というフラッシュメッセージを表示させること' do
          visit new_session_path
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          click_button 'ログイン'
          expect(page).to have_content 'ログインしました'
        end
      end
      context 'ログインに失敗した場合' do
        it '「メールアドレスまたはパスワードに誤りがあります」というフラッシュメッセージを表示させること' do
          visit new_session_path
          find('input[name="session[email]"]').set('failed_user@email.com')
          find('input[name="session[password]"]').set('failed_password')
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレスまたはパスワードに誤りがあります'
        end
      end
      context 'ログアウトした場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(user.email)
          find('input[name="session[password]"]').set(user.password)
          click_button 'ログイン'
        end
        it '「ログアウトしました」というフラッシュメッセージを表示させること' do
          click_link 'ログアウト'
          expect(page).to have_content 'ログアウトしました'
        end
      end
      context 'ユーザの登録に成功した場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          click_button 'ログイン'
        end
        it '「ユーザを登録しました」というフラッシュメッセージを表示させること' do
          visit new_admin_user_path
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('new_password')
          find('input[name="user[password_confirmation]"]').set('new_password')
          click_button '登録する'
          expect(page).to have_content 'ユーザを登録しました'
        end
      end
      context 'ユーザの更新に成功した場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          click_button 'ログイン'
        end
        it '「ユーザを更新しました」というフラッシュメッセージを表示させること' do
          visit edit_admin_user_path(user)
          find('input[name="user[name]"]').set('new_user_name')
          find('input[name="user[email]"]').set('new_user@email.com')
          find('input[name="user[password]"]').set('new_password')
          find('input[name="user[password_confirmation]"]').set('new_password')
          click_button '更新する'
          expect(page).to have_content 'ユーザを更新しました'
        end
      end
      context 'ユーザを削除した場合' do
        before do
          visit new_session_path
          find('input[name="session[email]"]').set(admin.email)
          find('input[name="session[password]"]').set(admin.password)
          click_button 'ログイン'
        end
        it '「ユーザを削除しました」というフラッシュメッセージを表示させること' do
          visit admin_users_path
          click_link '削除', href: admin_user_path(user)
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'ユーザを削除しました'
        end
      end
    end

    describe '12.メールアドレスの大文字と小文字の区別をなくす設定を追加すること' do
      it 'すでにあるメールアドレスの文字サイズを変えて登録しようとした場合、「メールアドレスはすでに使用されています」というバリデーションメッセージが表示される' do
        visit new_user_path
        find('input[name="user[name]"]').set('new_user_name')
        find('input[name="user[email]"]').set('User@email.com')
        find('input[name="user[password]"]').set('new_password')
        find('input[name="user[password_confirmation]"]').set('new_password')
        click_button '登録する'
        expect(page).to have_content 'メールアドレスはすでに使用されています'
      end
    end

    describe '13.ユーザとタスクにアソシエーションを組み、タスク一覧画面に自分が作成したタスクのみ表示させること' do
      let!(:second_user) { User.create(name: 'second_user_name', email: 'second_user@email.com', password: 'password', admin: false) }
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(user.email)
        find('input[name="session[password]"]').set(user.password)
        click_button 'ログイン'
      end
      it 'ユーザとタスクにアソシエーションを組み、タスク一覧画面に自分が作成したタスクのみ表示させること' do
        5.times do |n|
          Task.create(title: "task_title_#{n}", content: "task_content_#{n}", deadline_on: Date.today, priority: 0, status: 0, user_id: user.id)
          Task.create(title: "second_user_task_title_#{n}", content: "task_content_#{n}", deadline_on: Date.today, priority: 0, status: 0, user_id: second_user.id)
        end
        visit tasks_path
        5.times do |n|
          expect(page).to have_content "task_title_#{n}"
          expect(page).not_to have_content "second_user_task_title_#{n}"
        end
      end
    end

    describe '14.ログインをせずにログイン画面とアカウント登録画面以外にアクセスした場合、ログインページに遷移させ「ログインしてください」というフラッシュメッセージを表示させること' do
      let!(:task){Task.create(title: 'task_title', content: 'task_content', deadline_on: Date.today, priority: 0, status: 0, user_id: user.id)}
      it 'タスク一覧画面にアクセスした場合' do
        visit tasks_path
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
      it 'タスク詳細画面にアクセスした場合' do
        visit task_path(task)
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
      it 'タスク編集画面にアクセスした場合' do
        visit edit_task_path(task)
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
      it 'アカウント詳細画面にアクセスした場合' do
        visit user_path(user)
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
      it 'アカウント編集画面にアクセスした場合' do
        visit edit_user_path(user)
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
      it 'ユーザ一覧画面にアクセスした場合' do
        visit admin_users_path
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
      it 'ユーザ登録画面にアクセスした場合' do
        visit new_admin_user_path
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
      it 'ユーザ詳細画面にアクセスした場合' do
        visit admin_user_path(user)
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
      it 'ユーザ編集画面にアクセスした場合' do
        visit edit_admin_user_path(user)
        expect(page).to have_current_path(new_session_path)
        expect(page).to have_content 'ログインしてください'
      end
    end

    describe '15.ログイン中にログイン画面、あるいはアカウント登録画面にアクセスした場合、タスク一覧画面に遷移させ「ログアウトしてください」というフラッシュメッセージを表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it 'ログイン画面にアクセスした場合' do
        visit new_session_path
        expect(page).not_to have_current_path(new_session_path)
        expect(page).to have_content 'ログアウトしてください'
      end
      it 'アカウント登録画面にアクセスした場合' do
        visit new_user_path
        expect(page).not_to have_current_path(new_user_path)
        expect(page).to have_content 'ログアウトしてください'
      end
    end

    describe '16.他人のタスク詳細画面、あるいはタスク編集画面にアクセスしようとした場合、タスク一覧画面に遷移させ「アクセス権限がありません」というフラッシュメッセージを表示させること' do
      let!(:second_user) { User.create(name: 'second_user_name', email: 'second_user@email.com', password: 'password', admin: false) }
      let!(:second_user_task){Task.create(title: 'task_title', content: 'task_content', deadline_on: Date.today, priority: 0, status: 0, user_id: second_user.id)}
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(user.email)
        find('input[name="session[password]"]').set(user.password)
        click_button 'ログイン'
      end
      it 'タスク詳細画面にアクセスした場合' do
        visit task_path(second_user_task)
        expect(page).to have_current_path(tasks_path)
        expect(page).to have_content 'アクセス権限がありません'
      end
      it 'タスク編集画面にアクセスした場合' do
        visit edit_task_path(second_user_task)
        expect(page).to have_current_path(tasks_path)
        expect(page).to have_content 'アクセス権限がありません'
      end
    end

    describe '17.ユーザを削除した際、そのユーザに紐づいているすべてのタスクが削除されること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it 'ユーザを削除した際、そのユーザに紐づいているすべてのタスクが削除されること' do
        10.times do
          Task.create(title: 'task_title', content: 'task_content', deadline_on: Date.today, priority: 0, status: 0, user_id: user.id)
        end
        visit admin_users_path
        click_link '削除', href: admin_user_path(user)
        page.driver.browser.switch_to.alert.accept
        expect(Task.all.count).to eq 0
      end
    end

    describe '18.ユーザの登録画面と編集画面で管理者権限の付け外しができること' do
      let!(:second_admin) { User.create(name: 'second_admin_name', email: 'second_admin@email.com', password: 'password', admin: true) }
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it 'ユーザの登録画面で管理者権限の付け外しができること' do
        visit new_admin_user_path
        find('input[name="user[name]"]').set('new_user_name')
        find('input[name="user[email]"]').set('new_user@email.com')
        find('input[name="user[password]"]').set('password')
        find('input[name="user[password_confirmation]"]').set('password')
        check 'user[admin]'
        click_button '登録する'
        expect(User.find_by(email: 'new_user@email.com').admin).to eq true
      end
      it 'ユーザの編集画面で管理者権限の付け外しができること' do
        visit edit_admin_user_path(second_admin)
        find('input[name="user[name]"]').set('new_user_name')
        find('input[name="user[email]"]').set('new_user@email.com')
        find('input[name="user[password]"]').set('password')
        find('input[name="user[password_confirmation]"]').set('password')
        uncheck 'user[admin]'
        click_button '更新する'
        expect(User.find_by(email: 'new_user@email.com').admin).to eq false
      end
    end

    describe '19.一般ユーザが管理画面（新たに作成した4つの画面のいずれか）にアクセスした場合、タスク一覧画面に遷移させ「管理者以外アクセスできません」というフラッシュメッセージを表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(user.email)
        find('input[name="session[password]"]').set(user.password)
        click_button 'ログイン'
      end
      it 'ユーザ一覧画面にアクセスした場合、タスク一覧画面に遷移させ「管理者以外アクセスできません」というフラッシュメッセージを表示させること' do
        visit admin_users_path
        expect(page).to have_current_path(tasks_path)
        expect(page).to have_content '管理者以外アクセスできません'
      end
      it 'ユーザ登録画面にアクセスした場合、タスク一覧画面に遷移させ「管理者以外アクセスできません」というフラッシュメッセージを表示させること' do
        visit new_admin_user_path
        expect(page).to have_current_path(tasks_path)
        expect(page).to have_content '管理者以外アクセスできません'
      end
      it 'ユーザ詳細画面にアクセスした場合、タスク一覧画面に遷移させ「管理者以外アクセスできません」というフラッシュメッセージを表示させること' do
        visit admin_user_path(user)
        expect(page).to have_current_path(tasks_path)
        expect(page).to have_content '管理者以外アクセスできません'
      end
      it 'ユーザ編集画面にアクセスした場合、タスク一覧画面に遷移させ「管理者以外アクセスできません」というフラッシュメッセージを表示させること' do
        visit edit_admin_user_path(user)
        expect(page).to have_current_path(tasks_path)
        expect(page).to have_content '管理者以外アクセスできません'
      end
    end

    describe '20.管理者が一人しかいない状態でそのユーザを削除しようとした場合、モデルのコールバックを使って削除できないよう制御し、「管理者が0人になるため削除できません」というフラッシュメッセージを表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it '管理者が一人しかいない状態でそのユーザを削除しようとした場合、モデルのコールバックを使って削除できないよう制御し、「管理者が0人になるため削除できません」というフラッシュメッセージを表示させること' do
        visit admin_users_path
        click_link '削除', href: admin_user_path(admin)
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content '管理者が0人になるため削除できません'
      end
    end

    describe '21.管理者が一人しかいない状態でそのユーザから管理者権限を外す更新をしようとした場合、モデルのコールバックを使って更新できないよう制御し、「管理者が0人になるため権限を変更できません」というエラーメッセージを表示させること' do
      before do
        visit new_session_path
        find('input[name="session[email]"]').set(admin.email)
        find('input[name="session[password]"]').set(admin.password)
        click_button 'ログイン'
      end
      it '管理者が一人しかいない状態でそのユーザから管理者権限を外す更新をしようとした場合、モデルのコールバックを使って更新できないよう制御し、「管理者が0人になるため権限を変更できません」というエラーメッセージを表示させること' do
        visit edit_admin_user_path(admin)
        find('input[name="user[name]"]').set(admin.name)
        find('input[name="user[email]"]').set(admin.email)
        find('input[name="user[password]"]').set(admin.password)
        find('input[name="user[password_confirmation]"]').set(admin.password)
        uncheck 'user[admin]'
        click_button '更新する'
        expect(page).to have_content '管理者が0人になるため権限を変更できません'
      end
    end
  end
end
