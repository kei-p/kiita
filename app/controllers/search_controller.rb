class SearchController < ApplicationController
  def index
    @search_params = search_params
    @items = Item.includes(:user, :tags).search(@search_params).page(params[:page]).order(published_at: :desc)
  end

  private

  def search_params
    params[:q].strip
  end
end
