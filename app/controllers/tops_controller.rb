class TopsController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to feeds_top_path
  end

  def feeds
    @feeds = Feed.of_user(current_user, page: params[:page])
    @contents = {}
    @contents[:item] = Item.includes(:user, :tags).find(@feeds.select(&:content_item?).map(&:content_id))
    @contents[:user] = User.find(@feeds.select(&:content_user?).map(&:content_id))
    @followings = User.find(@feeds.map(&:following_user_id))
  end

  def items
    @items = Item.all.published.includes(:user, :tags).order(published_at: :desc).page(params[:page])
  end

  def stock
    @items = current_user.stock_items.includes(:user, :tags).order('stocks.created_at DESC').page(params[:page])
  end

  def mine
    @items = current_user.published_items.includes(:user, :tags).order(published_at: :desc).page(params[:page])
  end
end
