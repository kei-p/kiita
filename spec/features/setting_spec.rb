require 'rails_helper'

feature 'Setting' do
  given!(:user) do
    create(:user, email: 'mail@example.com', password: 'password', password_confirmation: 'password')
  end

  background do
    sign_in(user)
  end

  scenario 'twitter連携' do
    visit settings_path

    expect do
      click_on 'Twitterで連携'
      user.reload
    end.to change { [user.provider, user.uid] }.to(['twitter', 'tw_12345'])

    expect(current_path).to eq(settings_path)
    expect(page).to have_content('Twitterで連携済みです')
  end

  scenario '名前変更' do
    visit settings_path

    fill_in 'Name', with: 'new_name'

    expect do
      click_on '更新'
      user.reload
    end.to change { user.name }.to('new_name')

    expect(current_path).to eq(settings_path)
    expect(page).to have_content('ユーザー情報を更新しました')
  end
end
