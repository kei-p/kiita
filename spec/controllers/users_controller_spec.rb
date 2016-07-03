require 'rails_helper'

describe UsersController do
  let(:user) { create(:user, :registered) }
  let(:target_user) { create(:user, :registered) }

  before do
    request.env["HTTP_REFERER"] = root_url
  end

  describe 'GET #show' do
    it do
      get :show, id: target_user.id
      aggregate_failures do
        expect(assigns[:user]).to eq(target_user)
        expect(response).to redirect_to(user_items_path(target_user))
      end
    end
  end

  describe 'GET #followers' do
    before do
      3.times do
        create(:user, :registered).follow(target_user)
      end
    end

    it do
      get :followers, id: target_user.id
      aggregate_failures do
        expect(assigns[:users]).to eq(target_user.followers)
        expect(response).to render_template(:followers)
      end
    end
  end

  describe 'POST #follow' do
    before do
      sign_in(user)
    end

    it do
      expect do
        post :follow, id: target_user.id
      end.to change { user.followings.count }.by(1)

      aggregate_failures do
        expect(response).to redirect_to(:back)
      end
    end
  end

  describe 'DELETE #unfollow' do
    before do
      sign_in(user)
      user.follow(target_user)
    end

    it do
      expect do
        delete :unfollow, id: target_user.id
      end.to change { user.followings.count }.by(-1)

      aggregate_failures do
        expect(response).to redirect_to(:back)
      end
    end
  end
end
