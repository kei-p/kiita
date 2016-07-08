class ItemsController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorize, except: [:index, :show, :stock, :unstock]
  before_action :set_item, except: [:index]

  def index
    @items = @user.published_items.includes(:tags, :users).page(params[:page]).order(published_at: :desc)
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
      redirect_to [current_user, @item], notice: '記事を作成しました'
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      redirect_to [current_user, @item], notice: '記事を更新しました'
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    redirect_to user_items_path(current_user), notice: '記事を削除しました'
  end

  def stock
    current_user.stock(@item)
    redirect_to [@user, @item]
  end

  def unstock
    current_user.unstock(@item)
    redirect_to [@user, @item]
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize
    unauthorized unless @user == current_user
  end

  def set_item
    @item = @user.published_items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :body, :tags_name_notation)
  end
end
