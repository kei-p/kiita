class UsersController < ApplicationController
  before_action :set_user

  def show
    redirect_to user_items_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
