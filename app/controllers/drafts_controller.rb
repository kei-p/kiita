class DraftsController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!
  before_action :authorize
  before_action :set_draft, except: [:index, :new, :create]

  def index
    @drafts = @user.draft_items.includes(:tags, :user).page(params[:page]).order(created_at: :desc)
  end

  def show
  end

  def new
    @draft = current_user.items.build
  end

  def edit
  end

  def create
    @draft = current_user.items.build(draft_params)

    if @draft.save
      if @draft.published?
        redirect_to user_item_path(current_user, @draft), notice: '記事を公開しました'
      else
        redirect_to user_draft_path(current_user, @draft), notice: '下書きを作成しました'
      end
    else
      render :new
    end
  end

  def update
    if @draft.update(draft_params)
      if @draft.published?
        redirect_to user_item_path(current_user, @draft), notice: '記事を公開しました'
      else
        redirect_to user_draft_path(current_user, @draft), notice: '下書きを更新しました'
      end
    else
      render :edit
    end
  end

  def destroy
    @draft.destroy
    redirect_to user_drafts_path(current_user), notice: '下書きを削除しました'
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize
    unauthorized unless @user == current_user
  end

  def set_draft
    @draft = @user.draft_items.find(params[:id])
  end

  def draft_params
    params.require(:item).permit(:title, :body, :tags_name_notation, :publish)
  end
end
