require 'rails_helper'

describe TopsController do
  let(:user) { create(:user, :registered) }

  describe 'GET #show' do
    before do
      sign_in(user)
    end

    it do
      get :show
      aggregate_failures do
        expect(response).to redirect_to(feeds_top_path)
      end
    end
  end

  describe 'GET #feeds' do
    before do
      sign_in(user)

      u = create(:user, :registered)
      create(:item, user: u)

      user.follow(u)
    end

    it do
      get :feeds
      aggregate_failures do
        expect(assigns[:feeds]).not_to be_nil
        expect(response).to render_template(:feeds)
      end
    end
  end

  describe 'GET #items' do
    before do
      sign_in(user)

      u = create(:user, :registered)
      create(:item, user: u)
    end

    it do
      get :items
      aggregate_failures do
        expect(assigns[:items].map(&:id)).to eq(Item.all.map(&:id))
        expect(response).to render_template(:items)
      end
    end
  end

  describe 'GET #items' do
    before do
      sign_in(user)

      item = create(:item, user: user)
      user.stock(item)
    end

    it do
      get :stock
      aggregate_failures do
        expect(assigns[:items].map(&:id)).to eq(user.stock_items.map(&:id))
        expect(response).to render_template(:stock)
      end
    end
  end

  describe 'GET #mine' do
    before do
      sign_in(user)

      create(:item, user: user)
    end

    it do
      get :mine
      aggregate_failures do
        expect(assigns[:items].map(&:id)).to eq(user.items.map(&:id))
        expect(response).to render_template(:mine)
      end
    end
  end
end
