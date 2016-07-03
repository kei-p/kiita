require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:user) { create(:user, :registered) }

  describe '#after_save' do
    subject do
      item.tags_name_notation = tags_name_notation
      item.save!
    end

    let(:item) { build(:item, user: user) }
    let(:tags_name_notation) { 'a b c' }

    it do
      expect { subject }.to change { Item.count }.by(1)
                            .and change { Tag.count }.by(3)
      expect(Tag.find_by(name: 'a').items_count).to eq(1)
      expect(Tag.find_by(name: 'b').items_count).to eq(1)
      expect(Tag.find_by(name: 'c').items_count).to eq(1)
    end

    context 'すでに作成済みの場合' do
      before do
        create(:tag, name: 'a')
      end

      it do
        expect { subject }.to change { Item.count }.by(1)
                              .and change { Tag.count }.by(2)
        expect(Tag.find_by(name: 'a').items_count).to eq(1)
      end
    end

    context 'タグを付け替える場合' do
      before do
        item.tags_name_notation = 'a b c d e f'
        item.save!
      end

      it do
        expect { subject }.to change { item.tags.count }.to(3)
        expect(Tag.find_by(name: 'a').items_count).to eq(1)
        expect(Tag.find_by(name: 'f').items_count).to eq(0)
      end
    end
  end

  describe '#tags_name_notation' do
    let!(:item) { create(:item, user: user, tags_name_notation: tags_name_notation) }
    let(:tags_name_notation) { 'a b c' }

    it { expect(Item.find(item.id).tags_name_notation).to eq('a b c') }
  end
end
