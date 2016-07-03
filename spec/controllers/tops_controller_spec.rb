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
        expect(response).to redirect_to(feed_top_path)
      end
    end
  end

  describe 'GET #feed' do
    before do
      sign_in(user)

      u = create(:user, :registered)
      create(:item, user: u)

      user.follow(u)
    end

    it do
      get :feed
      aggregate_failures do
        expect(assigns[:items].map(&:id)).to eq(user.feed.map(&:id))
        expect(response).to render_template(:feed)
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
end
