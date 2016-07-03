require 'rails_helper'

describe SettingsController do
  let(:user) { create(:user, :registered) }

  describe 'GET #index' do
    before do
      sign_in(user)
    end

    it do
      get :index
      aggregate_failures do
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'PUT #update' do
    before do
      sign_in(user)
    end

    let(:update_params) do
      { name: 'NewName', profile: 'NewProfile' }
    end

    it do
      expect do
        put :update, user: update_params
        user.reload
      end.to change { user.name }.to('NewName')
             .and change { user.profile }.to('NewProfile')

      aggregate_failures do
        expect(response).to render_template(:index)
        expect(flash[:notice]).to eq('ユーザー情報を更新しました')
      end
    end
  end
end
