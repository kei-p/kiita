require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe '.find_or_initialize_by_name_notation' do
    subject { Tag.find_or_initialize_by_name_notation(notation) }
    let(:notation) { 'a b c' }

    it do
      expect(subject.count).to eq(3)
      expect(subject.select(&:new_record?).count).to eq(3)
    end

    context 'すでに作成済みの場合' do
      before do
        create(:tag, name: 'a')
      end

      it do
        expect(subject.count).to eq(3)
        expect(subject.select(&:new_record?).count).to eq(2)
        expect(subject.select(&:persisted?).count).to eq(1)
      end
    end
  end
end
