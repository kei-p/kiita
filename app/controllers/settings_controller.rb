class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def update
    if current_user.update(update_params)
      flash[:notice] = 'ユーザー情報を更新しました'
    end
    render :index
  end

  private

  def update_params
    params.require(:user).permit(:name)
  end
end
