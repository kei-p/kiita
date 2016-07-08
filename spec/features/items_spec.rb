require 'rails_helper'

feature 'Items' do
  given!(:user) { create(:user, :registered) }

  background do
    sign_in(user)
  end

  scenario '記事を投稿する' do
    visit new_user_item_path(user)

    within('#new_item') do
      fill_in 'Title', with: 'Title'
      fill_in 'Tags', with: 'A B C'
      fill_in 'Body', with: 'Body'

      expect { click_on '投稿する' }.to change { Item.count }.by(1)
    end

    item = Item.last
    expect(current_path).to eq(user_item_path(user, item))

    expect(item.user).to eq(user)
    expect(item.title).to eq('Title')
    expect(item.body).to eq('Body')
    expect(item.tags.count).to eq(3)
  end

  given(:item) { create(:item, user: user, title: 'Title', body: '#Body', tags_name_notation: 'A B C', created_at: Time.zone.now.yesterday) }

  scenario '記事を閲覧する' do
    visit user_item_path(user, item)

    expect(page).to have_content("#{item.published_at.to_date}に投稿しました")

    expect(page).to have_xpath('//h1', text: 'Body')
    expect(page).to have_link('投稿を編集', href: edit_user_item_path(user, item))
    expect(page).to have_link('削除', href: user_item_path(user, item))
  end

  scenario '他人の記事を閲覧する' do
    other_user = create(:user, :registered)
    other_user_item = create(:item, user: other_user)
    visit user_item_path(other_user, other_user_item)

    expect(page).not_to have_link('投稿を編集')
    expect(page).not_to have_link('削除')
  end

  scenario '記事を更新する' do
    visit user_item_path(user, item)

    click_on '投稿を編集'
    expect(current_path).to eq(edit_user_item_path(user, item))

    within("#edit_item_#{item.id}") do
      fill_in 'Title', with: 'NewTitle'
      fill_in 'Body', with: 'NewBody'

      expect do
        click_on '更新する'
        item.reload
      end.to change { [item.title, item.body] }.to(['NewTitle', 'NewBody'])
    end

    expect(current_path).to eq(user_item_path(user, item))
  end

  scenario '記事を削除する' do
    visit user_item_path(user, item)

    expect { click_on '削除' }.to change { Item.count }.by(-1)

    expect(current_path).to eq(user_items_path(user))
  end

  scenario '記事をストックする' do
    visit user_item_path(user, item)

    expect do
      click_on 'ストック'
      item.reload
    end.to change { item.stocks.count }.by(1)

    expect(current_path).to eq(user_item_path(user, item))
  end

  scenario '記事のストックを解除する' do
    user.stock(item)

    visit user_item_path(user, item)

    expect do
      click_on 'ストック解除'
      item.reload
    end.to change { item.stocks.count }.by(-1)

    expect(current_path).to eq(user_item_path(user, item))
  end
end
