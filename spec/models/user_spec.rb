require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#password_required?' do
    subject { user.password_required? }

    context 'ユーザー登録済みの場合' do
      let(:user) { create(:user, password: 'password', password_confirmation: 'password') }
      it { should be false }
    end

    context 'twitterによる登録時の場合' do
      let(:user) { build(:user, provider: 'twitter', uid: '1') }
      it { should be false }
    end

    context 'パスワードによる登録時の場合' do
      let(:user) { build(:user, provider: nil, uid: nil) }
      it { should be true }
    end
  end

  describe '#oauthorized?' do
    subject { user.oauthorized? }

    context 'providerとuidがある場合' do
      let(:user) { build(:user, provider: 'twitter', uid: '1') }
      it { should be true }
    end

    context 'providerとuidがnilの場合' do
      let(:user) { build(:user, provider: nil, uid: nil) }
      it { should be false }
    end
  end
end
