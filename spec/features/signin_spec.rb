require 'rails_helper'

feature 'Signin' do
  given!(:user) do
    create(:user, email: 'mail@example.com', password: 'password', password_confirmation: 'password',
                  provider: 'twitter', uid: 'tw_12345')
  end

  scenario 'ようこそ画面でパスワードを使ったログイン' do
    visit welcome_path

    fill_in 'Email', with: 'mail@example.com'
    fill_in 'Password', with: 'password'

    click_on 'ログイン'

    expect(current_path).to eq(feeds_top_path)
  end

  scenario 'ようこそ画面でtwitterを使ったログイン' do
    visit welcome_path

    click_on 'Twitterで新規登録/ログイン'

    expect(current_path).to eq(feeds_top_path)
  end

  scenario '認証画面でパスワードを使ったログイン' do
    visit new_user_session_path

    fill_in 'Email', with: 'mail@example.com'
    fill_in 'Password', with: 'password'

    click_on 'ログイン'

    expect(current_path).to eq(feeds_top_path)
  end

  scenario '認証画面でtwitterを使ったログイン' do
    visit new_user_session_path

    click_on 'Twitterで新規登録/ログイン'

    expect(current_path).to eq(feeds_top_path)
  end
end
