require_relative '../rails_helper'

RSpec.describe 'step3', type: :system do

  date_list = ["2025/10/01", "2025/12/01", "2025/01/01", "2025/05/01", "2025/03/01", "2025/11/01", "2025/02/01", "2025/09/01", "2025/04/01", "2025/06/01"]
  priority_list = [2, 0, 2, 1, 1, 0, 1, 2, 1, 2]
  status_list = [0, 2, 2, 0, 1, 1, 0, 2, 1, 2]
  10.times { |n| let!(:"task_#{n+2}") { Task.create(created_at: Date.today+n, title: "task_title_#{n+2}", content: "task_content_#{n+2}", deadline_on: date_list[n], priority: priority_list[n], status: status_list[n]) } }

  describe '基本要件' do
    describe '1.終了期限の入力フォームはdate_fieldを使って実装すること' do
      it '登録画面' do
        visit new_task_path
        expect(find('input[type="date"]')).to be_visible
      end
      it '編集画面' do
        visit edit_task_path(task_2)
        expect(find('input[type="date"]')).to be_visible
      end
    end
    describe '2. 優先度の入力フォームにはselectを使用し、「高」、「中」、「低」から選択できるようにすること' do
      it '登録画面' do
        visit new_task_path
        expect(find('select[name="task[priority]"]')).to be_visible
        select '高', from: 'task[priority]'
        select '中', from: 'task[priority]'
        select '低', from: 'task[priority]'
      end
      it '編集画面' do
        visit edit_task_path(task_2)
        expect(find('select[name="task[priority]"]')).to be_visible
        select '高', from: 'task[priority]'
        select '中', from: 'task[priority]'
        select '低', from: 'task[priority]'
      end
    end
    describe '3.ステータスの入力フォームには`select`を使用し、「未着手」、「着手中」、「完了」から選択できるようにすること' do
      it '登録画面' do
        visit new_task_path
        expect(find('select[name="task[status]"]')).to be_visible
        select '未着手', from: 'task[status]'
        select '着手中', from: 'task[status]'
        select '完了', from: 'task[status]'
      end
      it '編集画面' do
        visit edit_task_path(task_2)
        expect(find('select[name="task[status]"]')).to be_visible
        select '未着手', from: 'task[status]'
        select '着手中', from: 'task[status]'
        select '完了', from: 'task[status]'
      end
    end
    describe '4.タスク登録画面の優先度とステータスの入力フォームのデフォルト値は空欄にすること' do
      it '優先度の入力フォームのデフォルト値が空欄であること' do
        visit new_task_path
        expect(find('select[name="task[priority]"]').all('option')[0].text).to be_blank
      end
      it 'ステータスの入力フォームのデフォルト値が空欄であること' do
        visit new_task_path
        expect(find('select[name="task[status]"]').all('option')[0].text).to be_blank
      end
    end
    describe '5.検索機能の実装にはform_withを使用し、かつscope: :searchを設定すること' do
      it 'formタグが存在すること' do
        visit tasks_path
        expect(find('form')).to be_visible
      end
      it 'ステータス検索フォームのname属性がsearch[status]になっていること' do
        visit tasks_path
        expect(find('select[name="search[status]"]')).to be_visible
      end
    end
    describe '6.ステータスの検索フォームにはselectを使用し、「未着手」、「着手中」、「完了」から選択できるようにすること' do
      it 'セレクトボックスから「未着手」、「着手中」、「完了」を選択できること' do
        visit tasks_path
        select '未着手', from: 'search[status]'
        select '着手中', from: 'search[status]'
        select '完了', from: 'search[status]'
      end
    end
    describe '7.ステータスの検索フォームのデフォルト値は空欄にすること' do
      it 'ステータスの検索フォームのデフォルト値は空欄にすること' do
        visit tasks_path
        expect(find('select')).to be_visible
        expect(all('option')[0].text).to be_blank
      end
    end
  end

  describe '画面設計要件' do
    describe '8.検索を実行するボタンに「検索」という文字を表示させ、`search_task`というHTMLのid属性を付与すること' do
      it '検索を実行するボタンに「検索」という文字を表示させ、`search_task`というHTMLのid属性を付与すること' do
        visit tasks_path
        expect(page).to have_button '検索'
        expect(page).to have_css '#search_task'
      end
    end
    describe '9.一覧画面のテーブルヘッダーに「終了期限」、「優先度」、「ステータス」という文字で項目を追加すること' do
      it '一覧画面' do
        visit tasks_path
        expect(find("thead")).to have_content '終了期限'
        expect(find("thead")).to have_content '優先度'
        expect(find("thead")).to have_content 'ステータス'
      end
    end
    describe '10.タスク詳細画面に「終了期限」、「優先度」、「ステータス」の項目を追加すること' do
      it '一覧画面' do
        visit task_path(task_2)
        expect(page).to have_content '終了期限'
        expect(page).to have_content '優先度'
        expect(page).to have_content 'ステータス'
      end
    end
    describe '11.タスクの優先度は「高」、「中」、「低」で表示すること' do
      it '一覧画面' do
        visit tasks_path
        expect(page).to have_content '高'
        expect(page).to have_content '中'
        expect(page).to have_content '低'
      end
      it '詳細画面' do
        visit task_path(task_7)
        expect(page).to have_content '低'
        visit task_path(task_8)
        expect(page).to have_content '中'
        visit task_path(task_9)
        expect(page).to have_content '高'
      end
    end
    describe '12.タスクのステータスは「未着手」、「着手中」、「完了」で表示すること' do
      it '一覧画面' do
        visit tasks_path
        expect(page).to have_content '未着手'
        expect(page).to have_content '着手中'
        expect(page).to have_content '完了'
      end
      it '詳細画面' do
        visit task_path(task_8)
        expect(page).to have_content '未着手'
        visit task_path(task_10)
        expect(page).to have_content '着手中'
        visit task_path(task_11)
        expect(page).to have_content '完了'
      end
    end
    describe '13.終了期限を登録するフォームラベルに「終了期限」の文字を表示させること' do
      it '登録画面' do
        visit new_task_path
        expect(page).to have_selector 'label', text: '終了期限'
      end
      it '編集画面' do
        visit edit_task_path(task_2)
        expect(page).to have_selector 'label', text: '終了期限'
      end
    end
    describe '14.優先度を登録するフォームラベルに「優先度」の文字を表示させること' do
      it '登録画面' do
        visit new_task_path
        expect(page).to have_selector 'label', text: '優先度'
      end
      it '編集画面' do
        visit edit_task_path(task_2)
        expect(page).to have_selector 'label', text: '優先度'
      end
    end
    describe '15.ステータスを登録するフォームラベルに「ステータス」の文字を表示させること' do
      it '登録画面' do
        visit new_task_path
        expect(page).to have_selector 'label', text: 'ステータス'
      end
      it '編集画面' do
        visit edit_task_path(task_2)
        expect(page).to have_selector 'label', text: 'ステータス'
      end
    end
    describe '16.ステータス検索のフォームラベルに「ステータス」の文字を表示させること' do
      it 'ステータス検索のフォームラベルに「ステータス」の文字を表示させること' do
        visit tasks_path
        expect(page).to have_selector 'label', text: 'ステータス'
      end
    end
    describe '17.あいまい検索のフォームラベルに「タイトル」の文字を表示させること' do
      it 'あいまい検索のフォームラベルに「タイトル」の文字を表示させること' do
        visit tasks_path
        expect(page).to have_selector 'label', text: 'タイトル'
      end
    end
  end

  describe '機能要件' do
    describe '18.タスクを登録、編集する際、終了期限、優先度、ステータスを登録できるようにすること' do
      context '登録画面' do
        it '終了期限、優先度「高」、ステータス「未着手」を登録できる' do
          visit new_task_path
          find('input[name="task[title]"]').set('task_title')
          find('textarea[name="task[content]"]').set('task_content')
          find('input[name="task[deadline_on]"]').set(Date.today)
          select '高', from: 'task[priority]'
          select '未着手', from: 'task[status]'
          click_button '登録する'
          expect(page).to have_content 'task_title'
          expect(page).to have_content 'task_content'
          expect(page).to have_content '高'
          expect(page).to have_content '未着手'
        end
        it '終了期限、優先度「中」、ステータス「着手中」を登録できる' do
          visit new_task_path
          find('input[name="task[title]"]').set('task_title')
          find('textarea[name="task[content]"]').set('task_content')
          find('input[name="task[deadline_on]"]').set(Date.today.next_day)
          select '中', from: 'task[priority]'
          select '着手中', from: 'task[status]'
          click_button '登録する'
          expect(page).to have_content 'task_title'
          expect(page).to have_content 'task_content'
          expect(page).to have_content '中'
          expect(page).to have_content '着手中'
        end
        it '終了期限、優先度「低」、ステータス「完了」を登録できる' do
          visit new_task_path
          find('input[name="task[title]"]').set('task_title')
          find('textarea[name="task[content]"]').set('task_content')
          find('input[name="task[deadline_on]"]').set(Date.today.next_month)
          select '低', from: 'task[priority]'
          select '完了', from: 'task[status]'
          click_button '登録する'
          expect(page).to have_content 'task_title'
          expect(page).to have_content 'task_content'
          expect(page).to have_content '低'
          expect(page).to have_content '完了'
        end
      end
      context '編集画面' do
        it '異なる終了期限、優先度「高」、ステータス「未着手」に更新できる' do
          visit edit_task_path(task_2)
          find('input[name="task[deadline_on]"]').set(Date.today.next_day)
          select '高', from: 'task[priority]'
          select '未着手', from: 'task[status]'
          click_button '更新する'
          expect(page).to have_content 'task_title'
          expect(page).to have_content 'task_content'
          expect(page).to have_content '高'
          expect(page).to have_content '未着手'
        end
        it '異なる終了期限、優先度「中」、ステータス「着手中」に更新できる' do
          visit edit_task_path(task_2)
          find('input[name="task[deadline_on]"]').set(Date.today.next_month)
          select '中', from: 'task[priority]'
          select '着手中', from: 'task[status]'
          click_button '更新する'
          expect(page).to have_content 'task_title'
          expect(page).to have_content 'task_content'
          expect(page).to have_content '中'
          expect(page).to have_content '着手中'
        end
        it '異なる終了期限、優先度「低」、ステータス「完了」に更新できる' do
          visit edit_task_path(task_2)
          find('input[name="task[deadline_on]"]').set(Date.today.next_year)
          select '低', from: 'task[priority]'
          select '完了', from: 'task[status]'
          click_button '更新する'
          expect(page).to have_content 'task_title'
          expect(page).to have_content 'task_content'
          expect(page).to have_content '低'
          expect(page).to have_content '完了'
        end
      end
    end
    describe '19.タスクの登録、編集において、要件通りにバリデーションを追加すること' do
      it '登録画面' do
        visit new_task_path
        find('input[name="task[title]"]').set('task_title')
        find('textarea[name="task[content]"]').set('task_content')
        find('input[name="task[deadline_on]"]').set('')
        select '', from: 'task[priority]'
        select '', from: 'task[status]'
        click_button '登録する'
        expect(page).to have_content '終了期限を入力してください'
        expect(page).to have_content '優先度を入力してください'
        expect(page).to have_content 'ステータスを入力してください'
      end
      it '編集画面' do
        visit edit_task_path(task_2)
        find('input[name="task[deadline_on]"]').set(nil)
        click_button '更新する'
        expect(page).to have_content '終了期限を入力してください'
      end
    end
    describe '20.テーブルヘッダーの「終了期限」をクリックした際、タスクを終了期限の昇順にソートすること' do
      it 'タスクを終了期限の昇順で表示させること' do
        visit tasks_path
        click_on '終了期限'
        tr = all('tbody tr')
        expect(tr[0].text).to have_content 'task_title_4'
        expect(tr[1].text).to have_content 'task_title_8'
        expect(tr[2].text).to have_content 'task_title_6'
        expect(tr[3].text).to have_content 'task_title_10'
        expect(tr[4].text).to have_content 'task_title_5'
        expect(tr[5].text).to have_content 'task_title_11'
        expect(tr[6].text).to have_content 'task_title_9'
        expect(tr[7].text).to have_content 'task_title_2'
        expect(tr[8].text).to have_content 'task_title_7'
        expect(tr[9].text).to have_content 'task_title_3'
      end
    end
    describe '21.テーブルヘッダーの「優先度」をクリックした際、優先度の高い順にソートすること' do
      it '同じ優先度内の順番にかかわらず、高、中、低の順で表示させること' do
        visit tasks_path
        click_on '優先度'
        task_titles = all('tbody tr').map { |row| row.text[/task_title_\d+/] }

        expect(task_titles[0, 4]).to match_array %w[task_title_2 task_title_4 task_title_9 task_title_11]
        expect(task_titles[4, 4]).to match_array %w[task_title_5 task_title_6 task_title_8 task_title_10]
        expect(task_titles[8, 2]).to match_array %w[task_title_3 task_title_7]
      end
    end
    describe '22.一覧画面にステータス「未着手」、「着手中」、「完了」で検索する機能を実装すること' do
      it '未着手で検索できる' do
        visit tasks_path
        select '未着手', from: "search[status]"
        find('#search_task').click
        expect(page).to have_content 'task_title_2'
        expect(page).to have_content 'task_title_5'
        expect(page).to have_content 'task_title_8'
        expect(page).not_to have_content 'task_title_3'
        expect(page).not_to have_content 'task_title_4'
        expect(page).not_to have_content 'task_title_6'
        expect(page).not_to have_content 'task_title_7'
        expect(page).not_to have_content 'task_title_9'
        expect(page).not_to have_content 'task_title_10'
        expect(page).not_to have_content 'task_title_11'
      end
      it '未着中で検索できる' do
        visit tasks_path
        select '着手中', from: "search[status]"
        find('#search_task').click
        expect(page).to have_content 'task_title_6'
        expect(page).to have_content 'task_title_7'
        expect(page).to have_content 'task_title_10'
        expect(page).not_to have_content 'task_title_2'
        expect(page).not_to have_content 'task_title_3'
        expect(page).not_to have_content 'task_title_4'
        expect(page).not_to have_content 'task_title_5'
        expect(page).not_to have_content 'task_title_8'
        expect(page).not_to have_content 'task_title_9'
        expect(page).not_to have_content 'task_title_11'
      end
      it '完了で検索できる' do
        visit tasks_path
        select '完了', from: "search[status]"
        find('#search_task').click
        expect(page).to have_content 'task_title_3'
        expect(page).to have_content 'task_title_4'
        expect(page).to have_content 'task_title_9'
        expect(page).to have_content 'task_title_11'
        expect(page).not_to have_content 'task_title_2'
        expect(page).not_to have_content 'task_title_5'
        expect(page).not_to have_content 'task_title_6'
        expect(page).not_to have_content 'task_title_7'
        expect(page).not_to have_content 'task_title_8'
        expect(page).not_to have_content 'task_title_10'
      end
    end
    describe '23.一覧画面にタイトルであいまい検索する機能を実装すること' do
      it '一覧画面にタイトルであいまい検索する機能を実装すること' do
        visit tasks_path
        find('input[name="search[title]"]').set('task_title_1')
        find('#search_task').click
        expect(page).to have_content 'task_title_10'
        expect(page).to have_content 'task_title_11'
        expect(page).not_to have_content 'task_title_2'
        expect(page).not_to have_content 'task_title_3'
        expect(page).not_to have_content 'task_title_4'
        expect(page).not_to have_content 'task_title_5'
        expect(page).not_to have_content 'task_title_6'
        expect(page).not_to have_content 'task_title_7'
        expect(page).not_to have_content 'task_title_8'
        expect(page).not_to have_content 'task_title_9'
      end
    end
    describe '24.検索機能はタイトルとステータスの両方で絞り込み検索ができるようにすること' do
      it '検索機能はタイトルとステータスの両方で絞り込み検索ができるようにすること' do
        visit tasks_path
        select '着手中', from: "search[status]"
        find('input[name="search[title]"]').set('task_title_1')
        find('#search_task').click
        expect(page).to have_content 'task_title_10'
        expect(page).not_to have_content 'task_title_2'
        expect(page).not_to have_content 'task_title_3'
        expect(page).not_to have_content 'task_title_4'
        expect(page).not_to have_content 'task_title_5'
        expect(page).not_to have_content 'task_title_6'
        expect(page).not_to have_content 'task_title_7'
        expect(page).not_to have_content 'task_title_8'
        expect(page).not_to have_content 'task_title_9'
        expect(page).not_to have_content 'task_title_11'
      end
    end
  end
end
