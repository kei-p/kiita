require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '#after_save' do
    subject do
      item.tags_name_notation = tags_name_notation
      item.save!
    end

    let(:user) { create(:user, :registered) }
    let(:item) { build(:item) }
    let(:tags_name_notation) { 'a b c' }

    it do
      expect { subject }.to change { Item.count }.by(1)
                            .and change { Tag.count }.by(3)
    end

    context 'すでに作成済みの場合' do
      before do
        create(:tag, name: 'a')
      end

      it do
        expect { subject }.to change { Item.count }.by(1)
                              .and change { Tag.count }.by(2)
      end
    end

    context 'タグを付け替える場合' do
      before do
        item.tags_name_notation = 'a b c d e f'
        item.save!
      end

      it do
        expect { subject }.to change { item.tags.count }.to(3)
      end
    end
  end

  describe '#after_initialize' do
    before do
      item.save!
    end

    let(:item) { build(:item, tags_name_notation: tags_name_notation) }
    let(:tags_name_notation) { 'a b c' }

    it { expect(Item.find(item.id).tags_name_notation).to eq('a b c') }
  end
end
