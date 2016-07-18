require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:user) { create(:user, :registered) }

  describe '#after_save', clean: :truncation do
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

    context '下書きの場合' do
      let(:item) { build(:draft, user: user) }

      it do
        expect { subject }.to change { Item.count }.by(1)
                              .and change { Tag.count }.by(3)
        expect(Tag.find_by(name: 'a').items_count).to eq(0)
        expect(Tag.find_by(name: 'b').items_count).to eq(0)
        expect(Tag.find_by(name: 'c').items_count).to eq(0)
      end
    end

    context 'タグを付け替える場合' do
      before do
        item.tags_name_notation = 'a b c d e f'
        item.save!
        item.reload
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

    it { expect(Item.find(item.id).tags_name_notation).to eq("a b c") }
  end

  describe '#search' do
    context 'mix' do
      subject do
        q = Item.parse_query(query)
        Item.search(q).result
      end
      before do
        create(:item, user: create(:user, :registered, name: 'user_name1'), title: 'Title1', tags_name_notation: 'tag_name1')
        create(:item, user: create(:user, :registered, name: 'user_name2'), title: 'Title2', tags_name_notation: 'tag_name2')
      end

      let(:query) { 'user:user_name1 tag:tag_name1 Ti tle 1' }
      it { expect(subject.count).to eq(1) }
    end


    context 'title' do
      subject do
        q = Item.parse_query(query.join(' '))
        Item.search(q).result
      end
      before do
        create(:item, user: create(:user, :registered, name: 'user_name'), title: 'Title1', tags_name_notation: 'tag_name')
        create(:item, user: create(:user, :registered, name: 'user_name'), title: 'Title2', tags_name_notation: 'tag_name')
      end

      context 'search title' do
        let(:query) { %w(itle) }
        it { expect(subject.count).to eq(2) }
      end

      context 'search ti le' do
        let(:query) { %w(it le) }
        it { expect(subject.count).to eq(2) }
      end

      context 'search ti le 1' do
        let(:query) { %w(it le 1) }
        it { expect(subject.count).to eq(1) }
      end

      context 'search ti le 3' do
        let(:query) { %w(it le 3) }
        it { expect(subject.count).to eq(0) }
      end

      context 'search \'sanitize' do
        let(:query) { %w('sanitize) }
        it { expect(subject.to_sql).to match(/\\'sanitize/) }
      end
    end

    context 'user' do
      subject do
        q = Item.parse_query(query.map { |u| "user:#{u}"}.join(' '))
        Item.search(q).result
      end
      before do
        create(:item, user: create(:user, :registered, name: 'user_name1'), title: 'Title', tags_name_notation: 'tag_name')
        create(:item, user: create(:user, :registered, name: 'user_name2'), title: 'Title', tags_name_notation: 'tag_name')
      end

      context 'search user_name1' do
        let(:query) { %w(user_name1) }
        it { expect(subject.count).to eq(1) }
      end

      context 'search user_name' do
        let(:query) { %w(user_name) }
        it { expect(subject.count).to eq(0) }
      end
    end

    context 'tag' do
      subject do
        q = Item.parse_query(query.map { |t| "tag:#{t}"}.join(' '))
        Item.search(q).result
      end
      before do
        create(:item, user: create(:user, :registered, name: 'user_name'), title: 'Title', tags_name_notation: 'tag_name1')
        create(:item, user: create(:user, :registered, name: 'user_name'), title: 'Title', tags_name_notation: 'tag_name2')
        create(:item, user: create(:user, :registered, name: 'user_name'), title: 'Title', tags_name_notation: 'tag_name1 tag_name2')
      end

      context 'search tag_name1' do
        let(:query) { %w(tag_name1) }
        it { expect(subject.count).to eq(2) }
      end

      context 'search tag_name' do
        before do
          pending "tags_name_notation を enclose させる"
        end
        let(:query) { %w(tag_name) }
        it { expect(subject.count).to eq(0) }
      end

      context 'search tag_name1 tag_name2' do
        let(:query) { %w(tag_name1 tag_name2) }
        it { expect(subject.count).to eq(1) }
      end

      context 'search \'sanitize' do
        let(:query) { %w('sanitize) }
        it { expect(subject.to_sql).to match(/\\'sanitize/) }
      end
    end
  end
end
