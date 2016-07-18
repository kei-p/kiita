class SearchController < ApplicationController
  def index
    @search_params = search_params
    if @search_params.blank?
      @items = Item.none
    else
      q = Item.parse_query(@search_params)
      result = Item.search(q).result
      @items = result.includes(:user, :tags).page(params[:page]).order(published_at: :desc)
    end
  end

  private

  def search_params
    params[:q].strip
  end
end
