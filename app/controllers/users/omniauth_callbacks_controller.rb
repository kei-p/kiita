class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    if current_user
      current_user.set_oauth(oauth)
      current_user.save!
      redirect_to settings_path, notice: 'twitter連携をしました'
    else
      @user = User.find_or_initialize_by_oauth(oauth)
      if @user.persisted?
        @user.update(icon_url: oauth.info.image)
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.twitter_data"] = oauth.except(:extra)
        redirect_to new_user_registration_url
      end
    end
  end

  private
  def oauth
    request.env["omniauth.auth"]
  end
end
