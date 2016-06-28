class TopsController < ApplicationController
  before_action :authenticate_user!
  def show
    redirect_to feed_top_path
  end

  def feed
  end

  def items
    @items = Item.all.includes(:user).page(params[:page]).per(10).order(created_at: :desc)
  end
end
