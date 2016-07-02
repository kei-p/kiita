require 'rails_helper'

feature 'Users' do
  given!(:user) { create(:user, :registered) }

  given!(:follow_user) { create(:user, :registered) }

  background do
    sign_in(user)
  end

  scenario 'ユーザーをフォローする' do
    visit user_path(follow_user)

    expect do
      click_on 'フォロー'
    end.to change { user.followings.count }.by(1)
           .and change { follow_user.followers.count }.by(1)

    expect(page).to have_button('フォロー解除')
  end

  scenario 'ユーザーのフォローを解除する' do
    user.follow(follow_user)

    visit user_path(follow_user)

    expect do
      click_on 'フォロー解除'
    end.to change { user.followings.count }.by(-1)
           .and change { follow_user.followers.count }.by(-1)

    expect(page).to have_button('フォロー')
  end
end
