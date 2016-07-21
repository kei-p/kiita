class DraftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draft, except: [:index, :new, :create]

  def index
    @drafts = current_user.draft_items.includes(:tags).page(params[:page]).order(created_at: :desc)
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
        redirect_to draft_path(@draft), notice: '下書きを作成しました'
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
        redirect_to draft_path(@draft), notice: '下書きを更新しました'
      end
    else
      render :edit
    end
  end

  def destroy
    @draft.destroy
    redirect_to drafts_path, notice: '下書きを削除しました'
  end

  private

  def set_draft
    @draft = current_user.draft_items.find(params[:id])
  end

  def draft_params
    params.require(:item).permit(:title, :body, :tag_names, :publish)
  end
end
