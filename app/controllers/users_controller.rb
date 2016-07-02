class UsersController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!, only: [:follow, :unfollow]

  def show
    redirect_to user_items_path(@user)
  end

  def follow
    current_user.follow(@user)
    redirect_to user_path(@user)
  end

  def unfollow
    current_user.unfollow(@user)
    redirect_to user_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
