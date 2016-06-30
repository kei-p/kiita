class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    @items = @tag.items.includes(:user, :tags).page(params[:page]).per(10)
  end
end
