class WelcomeController < ApplicationController
  layout 'no_header'

  def index
    redirect_to top_path if current_user
  end
end
