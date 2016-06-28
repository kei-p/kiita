module TopsHelper
  def top_tab_items
    [
      [ 'フィード', feed_top_path ],
      [ 'すべての投稿', items_top_path ],
    ].map { |title, path| Hashie::Mash.new(title: title, path: path) }
  end
end
