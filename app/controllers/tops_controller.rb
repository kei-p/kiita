class TopsController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to feed_top_path
  end

  def feed
    @items = current_user.feed.includes(:user, :tags).order(created_at: :desc).page(params[:page])
  end

  def items
    @items = Item.all.includes(:user, :tags).order(created_at: :desc).page(params[:page])
  end

  def stock
    @items = current_user.stock_items.includes(:user, :tags).order('stocks.created_at DESC').page(params[:page])
  end

  def mine
    @items = current_user.items.includes(:tags).order(created_at: :desc).page(params[:page])
  end
end
