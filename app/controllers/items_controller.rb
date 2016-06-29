class ItemsController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!, except: [:show]
  before_action :authorize, except: [:show]
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def index
    @items = @user.items.includes(:user, :tags).page(params[:page]).per(10)
  end

  def show
  end

  def new
    @item = current_user.items.build
  end

  def edit
  end

  def create
    @item = current_user.items.build(item_params)

    if @item.save
      redirect_to [current_user, @item], notice: 'Item was successfully created.'
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      redirect_to [current_user, @item], notice: 'Item was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    redirect_to user_items_path(current_user), notice: 'Item was successfully destroyed.'
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize
    unauthorized unless @user == current_user
  end

  def set_item
    @item = @user.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :body, :tags_name_notation)
  end
end
