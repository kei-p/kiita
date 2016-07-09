require 'rails_helper'

feature 'Search' do
  given!(:user) { create(:user, :registered) }

  background do
    sign_in(user)
    create(:item, user: user, title: 'Title')
  end

  scenario '記事を検索する', js: true do
    visit top_path

    find('#headerSearchForm input').set("itl")
    page.execute_script("$('#headerSearchForm').submit()")

    expect(page).to have_content('Title')
  end
end
