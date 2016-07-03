require 'rails_helper'

describe TagsController do
  describe 'GET #index' do
    before do
      [1, 2, 3].each { |i| create(:tag, items_count: i) }
    end

    it do
      get :index
      aggregate_failures do
        expect(assigns[:tags]).to eq(assigns[:tags].reorder(items_count: :desc))
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #show' do
    before do
      item.tags << tag
    end

    let(:tag) { create(:tag) }
    let(:item) { create(:item, user: create(:user, :registered)) }

    it do
      get :show, id: tag.id
      aggregate_failures do
        expect(assigns[:tag]).to eq(tag)
        expect(assigns[:items]).to eq(tag.items)
        expect(response).to render_template(:show)
      end
    end
  end
end
