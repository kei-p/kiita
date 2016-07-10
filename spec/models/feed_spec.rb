require 'rails_helper'

describe Feed do
  describe '#of_user' do
    subject { Feed.of_user(user, page: page, per: per) }

    let(:page) { 1 }
    let(:per)  { 10 }
    let(:user) { create(:user, :registered) }
    let(:follow_user) { create(:user, :registered, id: 200) }

    context 'paging' do
      before do
        create_list(:item, 11, user: follow_user)
        user.follow(follow_user)
      end

      context 'page 1 per 10' do
        let(:page) { 1 }
        let(:per) { 10 }
        it { expect(subject.count).to eq(10) }
        it { expect(subject.current_page).to eq(1) }
        it { expect(subject.total_pages).to eq(2) }
      end

      context 'page 2 per 10' do
        let(:page) { 2 }
        let(:per) { 10 }
        it { expect(subject.count).to eq(1) }
        it { expect(subject.current_page).to eq(2) }
        it { expect(subject.total_pages).to eq(2) }
      end

      context 'page 1 per 5' do
        let(:page) { 1 }
        let(:per) { 5 }
        it { expect(subject.count).to eq(5) }
        it { expect(subject.current_page).to eq(1) }
        it { expect(subject.total_pages).to eq(3) }
      end
    end

    context 'フォローしているユーザーが投稿した記事を取得' do
      before do
        create(:item, id: 100, user: follow_user)
      end

      context 'フォローしてるとき' do
        before do
          user.follow(follow_user)
        end

        it { expect(subject.count).to eq(1) }

        it do
          feed = subject.first
          expect(feed.content_id).to eq(100)
          expect(feed.following_user_id).to eq(200)
          expect(feed.feed_type).to eq(:following_user_create_item)
          expect(feed.content_type).to eq(:item)
        end
      end

      context 'フォローしてないとき' do
        it { expect(subject.count).to eq(0) }
      end
    end

    context 'フォローしているユーザーがストックした記事を取得' do
      before do
        item = create(:item, id: 100, user: create(:user, :registered))
        follow_user.stock(item)
      end

      context 'フォローしてるとき' do
        before do
          user.follow(follow_user)
        end

        it { expect(subject.count).to eq(1) }

        it do
          feed = subject.first
          expect(feed.content_id).to eq(100)
          expect(feed.following_user_id).to eq(200)
          expect(feed.feed_type).to eq(:following_user_stock_item)
          expect(feed.content_type).to eq(:item)
        end
      end

      context 'フォローしてないとき' do
        it { expect(subject.count).to eq(0) }
      end
    end

    context 'フォローしているユーザーがフォローしているユーザーを取得' do
      before do
        user = create(:user, :registered, id: 100)
        follow_user.follow(user)
      end

      context 'フォローしてるとき' do
        before do
          user.follow(follow_user)
        end

        it { expect(subject.count).to eq(1) }

        it do
          feed = subject.first
          expect(feed.content_id).to eq(100)
          expect(feed.following_user_id).to eq(200)
          expect(feed.feed_type).to eq(:following_user_follow_user)
          expect(feed.content_type).to eq(:user)
        end
      end

      context 'フォローしてないとき' do
        it { expect(subject.count).to eq(0) }
      end
    end
  end
end
