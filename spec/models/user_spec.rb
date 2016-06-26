require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#password_required?' do
    subject { user.password_required? }

    context do
      let(:user) { build(:user, provider: 'twitter', uid: '1') }
      it { should be false }
    end

    context do
      let(:user) { build(:user, provider: nil, uid: '1') }
      it { should be true }
    end

    context do
      let(:user) { build(:user, provider: 'twitter', uid: nil) }
      it { should be true }
    end
  end
end
