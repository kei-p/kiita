module UsersHelper
  def user_icon_url(user)
    user.icon_url || asset_path('anonymous_icon.png')
  end

  def user_tab_items(user)
    [
      [ 'Items', user_items_path(user) ],
    ].map { |title, path| Hashie::Mash.new(title: title, path: path) }
  end
end
