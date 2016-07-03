module TopsHelper
  def top_tab_items
    [
      [ 'フィード', feed_top_path, nil ],
      [ 'すべての投稿', items_top_path, nil ],
      [ '自分の投稿', mine_top_path, 'pull-right' ],
      [ 'ストック', stock_top_path, 'pull-right' ],
    ].map { |title, path, class_name| Hashie::Mash.new(title: title, path: path, class_name: class_name.to_s) }
  end
end
