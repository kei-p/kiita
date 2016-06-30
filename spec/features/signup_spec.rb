require 'rails_helper'

feature 'Signup' do
  scenario 'パスワードによる登録' do
    visit new_user_registration_path

    fill_in 'Name', with: 'name'
    fill_in 'Email', with: 'mail@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    expect { click_on 'Sign up' }.to change { User.count }.by(1)

    expect(current_path).to eq(feed_top_path)
    u = User.last
    expect(u.name).to eq('name')
    expect(u.email).to eq('mail@example.com')
    expect(u.encrypted_password).not_to be_empty
  end

  scenario 'twitterによる登録' do
    visit user_twitter_omniauth_authorize_path

    expect(current_path).to eq(new_user_registration_path)
    expect(find_field('Name').value).to eq('tw_name')
    expect(page).not_to have_field('Password')
    expect(page).not_to have_field('Password confirmation')

    fill_in 'Email', with: 'mail@example.com'
    expect { click_on 'Sign up' }.to change { User.count }.by(1)

    expect(current_path).to eq(feed_top_path)
    u = User.last
    expect(u.name).to eq('tw_name')
    expect(u.email).to eq('mail@example.com')
    expect(u.provider).to eq('twitter')
    expect(u.uid).to eq('tw_12345')
  end
end
