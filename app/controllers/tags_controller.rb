class TagsController < ApplicationController
  def index
    @tags = Tag.page(params[:page]).order(items_count: :desc)
  end

  def show
    @tag = Tag.find(params[:id])
    @items = @tag.items.includes(:user, :tags).page(params[:page])
  end
end
