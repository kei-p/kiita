class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    # TODO: authの作成
    puts request.env['omniauth.auth']
    redirect_to welcome_path
  end
end
