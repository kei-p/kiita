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

  describe '#stock' do
    let(:user) { create(:user, :registered) }
    let(:item) { create(:item, user: create(:user, :registered)) }

    it do
      expect { user.stock(item) }.to change { user.stock_items.count }.by(1)
    end
  end

  describe '#stock?' do
    subject { user.stock?(item)  }
    let(:user) { create(:user, :registered) }
    let(:item) { create(:item, user: create(:user, :registered)) }

    context 'ストック済み' do
      before do
        user.stock(item)
      end
      it { is_expected.to eq(true) }
    end

    context '未ストック' do
      it { is_expected.to eq(false) }
    end
  end

  describe '#unstock' do
    let(:user) { create(:user, :registered) }
    let(:item) { create(:item, user: create(:user, :registered)) }
    before do
      user.stock(item)
    end

    it do
      expect { user.unstock(item) }.to change { user.stock_items.count }.by(-1)
    end
  end

  describe '#follow' do
    let(:user) { create(:user, :registered) }
    let(:target_user) { create(:user, :registered) }
    it do
      expect do
        user.follow(target_user)
      end.to change { user.followings.count }.by(1)
             .and change { target_user.followers.count }.by(1)
    end
  end

  describe '#follow?' do
    subject { user.follow?(target_user)  }
    let(:user) { create(:user, :registered) }
    let(:target_user) { create(:user, :registered) }

    context 'ストック済み' do
      before do
        user.follow(target_user)
      end
      it { is_expected.to eq(true) }
    end

    context '未ストック' do
      it { is_expected.to eq(false) }
    end
  end

  describe '#unfollow' do
    let(:user) { create(:user, :registered) }
    let(:target_user) { create(:user, :registered) }

    before do
      user.follow(target_user)
    end

    it do
      expect do
        user.unfollow(target_user)
      end.to change { user.followings.count }.by(-1)
             .and change { target_user.followers.count }.by(-1)
    end
  end

  describe '#feed' do
    before do
      create(:item, user: follow_user)
      create(:item, user: not_follow_user)

      user.follow(follow_user)
    end

    let(:user) { create(:user, :registered) }
    let(:follow_user) { create(:user, :registered) }
    let(:not_follow_user) { create(:user, :registered) }

    it do
      feed = user.feed.map(&:id)
      expect(feed).to include(*follow_user.items.map(&:id))
      expect(feed).not_to include(*not_follow_user.items.map(&:id))
    end
  end
end
