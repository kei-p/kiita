require 'rails_helper'

describe DraftsController, focus: true do
  let(:draft) { create(:draft, user: author) }
  let(:author) { create(:user, :registered) }
  let(:user) { author }

  describe 'GET #index' do
    before do
      sign_in(user)
      create_list(:draft, 3, user: author)
    end

    it do
      get :index
      aggregate_failures do
        expect(assigns[:drafts]).to eq(assigns[:drafts].reorder(created_at: :desc))
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #show' do
    before do
      sign_in(user)
    end

    it do
      get :show, id: draft.id
      aggregate_failures do
        expect(assigns[:draft]).to eq(draft)
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET #new' do
    before do
      sign_in(user)
    end

    it do
      get :new

      aggregate_failures do
        expect(assigns[:draft]).not_to be_nil
        expect(assigns[:draft].user).to eq(author)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    before do
      sign_in(user)
    end

    it do
      get :edit, id: draft.id

      aggregate_failures do
        expect(assigns[:draft]).to eq(draft)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'POST #create' do
    before do
      sign_in(user)
    end

    subject do
      post :create, item: draft_params
    end

    let(:draft_params) do
      { title: 'Title', body: 'Body', tag_names: 'A B C'}
    end

    context '自分の下書きを投稿' do
      let(:user) { author }

      it do
        expect do
          subject
        end.to change { Item.count }.by(1)

        aggregate_failures do
          draft = Item.last
          expect(draft.title).to eq('Title')
          expect(draft.body).to eq('Body')
          expect(draft.published?).to eq(false)
          expect(draft.tags.count).to eq(3)

          expect(response).to redirect_to(draft_path(draft))
          expect(flash[:notice]).to eq('下書きを作成しました')
        end
      end
    end

    context '自分の下書きを公開' do
      let(:user) { author }
      let(:draft_params) do
        { title: 'Title', body: 'Body', tag_names: 'A B C', publish: "1"}
      end

      it do
        expect do
          subject
        end.to change { Item.count }.by(1)

        aggregate_failures do
          draft = Item.last
          expect(draft.title).to eq('Title')
          expect(draft.body).to eq('Body')
          expect(draft.published?).to eq(true)
          expect(draft.tags.count).to eq(3)

          expect(response).to redirect_to(user_item_path(author, draft))
          expect(flash[:notice]).to eq('記事を公開しました')
        end
      end
    end
  end

  describe 'PUT #update' do
    before do
      sign_in(user)
    end

    subject do
      put :update, id: draft.id, item: draft_params
      draft.reload
    end

    let(:draft_params) do
      { title: 'NewTitle', body: 'NewBody', tag_names: 'A B C D'}
    end

    context '自分の下書きを編集' do
      let(:user) { author }
      it do
        expect do
          subject
        end.to change { draft.title }.to('NewTitle')
               .and change { draft.body }.to('NewBody')
               .and change { draft.tags.count }.to(4)

        aggregate_failures do
          expect(response).to redirect_to(draft_path(draft))
          expect(flash[:notice]).to eq('下書きを更新しました')
        end
      end
    end

    context '自分の下書きを公開' do
      let(:user) { author }

      let(:draft_params) do
        { title: 'NewTitle', body: 'NewBody', tag_names: 'A B C D', publish: "1" }
      end

      it do
        expect do
          subject
        end.to change { draft.title }.to('NewTitle')
               .and change { draft.body }.to('NewBody')
               .and change { draft.tags.count }.to(4)

        aggregate_failures do
          expect(response).to redirect_to(user_item_path(author, draft))
          expect(flash[:notice]).to eq('記事を公開しました')
        end
      end
    end

    context '他人の下書きを編集' do
      let(:user) { create(:user, :registered) }
      it do
        expect do
          subject
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in(user)
      draft
    end

    subject do
      delete :destroy, id: draft.id
    end

    context '自分の下書きを削除' do
      let(:user) { author }
      it do
        expect do
          subject
        end.to change { Item.count }.by(-1)

        aggregate_failures do
          expect(response).to redirect_to(drafts_path)
          expect(flash[:notice]).to eq('下書きを削除しました')
        end
      end
    end

    context '他人の下書きを削除' do
      let(:user) { create(:user, :registered) }
      it do
        expect do
          subject
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
