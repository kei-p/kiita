class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    @user = User.find_or_initialize_by_oauth(oauth)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    else
      @user.attributes = {
        name: oauth.info.name
      }
      session["devise.twitter_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url
    end
  end

  private

  def oauth
    request.env["omniauth.auth"]
  end

end
