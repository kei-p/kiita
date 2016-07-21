require 'rails_helper'

describe ItemsController do
  let(:item) { create(:item, user: author) }
  let(:author) { create(:user, :registered) }
  let(:user) { author }

  describe 'GET #index' do
    before do
      create_list(:item, 3, user: author)
    end

    it do
      get :index, user_id: author.id
      aggregate_failures do
        expect(assigns[:items]).to eq(assigns[:items].reorder(published_at: :desc))
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #show' do
    it do
      get :show, user_id: author.id, id: item.id
      aggregate_failures do
        expect(assigns[:item]).to eq(item)
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET #edit' do
    before do
      sign_in(user)
    end

    it do
      get :edit, user_id: author.id, id: item.id

      aggregate_failures do
        expect(assigns[:item]).to eq(item)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'PUT #update' do
    before do
      sign_in(user)
    end

    subject do
      put :update, user_id: author.id, id: item.id, item: item_params
      item.reload
    end

    let(:item_params) do
      { title: 'NewTitle', body: 'NewBody', tag_names: 'A B C D'}
    end

    context '自分の記事を編集' do
      let(:user) { author }
      it do
        expect do
          subject
        end.to change { item.title }.to('NewTitle')
               .and change { item.body }.to('NewBody')
               .and change { item.tags.count }.to(4)

        aggregate_failures do
          expect(response).to redirect_to(user_item_path(author, item))
          expect(flash[:notice]).to eq('記事を更新しました')
        end
      end
    end

    context '他人の記事を投稿' do
      let(:user) { create(:user, :registered) }
      it do
        expect do
          subject
        end.to_not change { item }

        aggregate_failures do
          expect(response).to redirect_to(top_path)
          expect(flash[:alert]).to eq('権限がありません')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in(user)
      item
    end

    subject do
      delete :destroy, user_id: author.id, id: item.id
    end

    context '自分の記事を削除' do
      let(:user) { author }
      it do
        expect do
          subject
        end.to change { Item.count }.by(-1)

        aggregate_failures do
          expect(response).to redirect_to(user_items_path(author))
          expect(flash[:notice]).to eq('記事を削除しました')
        end
      end
    end

    context '自分の記事を削除' do
      let(:user) { create(:user, :registered) }
      it do
        expect do
          subject
        end.not_to change { Item.count }

        aggregate_failures do
          expect(response).to redirect_to(top_path)
          expect(flash[:alert]).to eq('権限がありません')
        end
      end
    end
  end

  describe 'POST #stock' do
    before do
      sign_in(user)
    end

    it do
      expect do
        post :stock, user_id: author.id, id: item.id
      end.to change { Stock.count }.by(1)

      aggregate_failures do
        expect(response).to redirect_to(user_item_path(author, item))
      end
    end
  end

  describe 'DELETE #unstock' do
    before do
      sign_in(user)
      user.stock(item)
    end

    it do
      expect do
        delete :unstock, user_id: author.id, id: item.id
      end.to change { Stock.count }.by(-1)

      aggregate_failures do
        expect(response).to redirect_to(user_item_path(author, item))
      end
    end
  end
end
