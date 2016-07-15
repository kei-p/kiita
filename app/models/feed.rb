# 僕自身使ったことはないのですが https://github.com/chaps-io/public_activity を使えばすっきり書けそうな気もします。
# 探せば他にも便利なgemありそうな感じがします
class Feed
  attr_accessor :feed_type, :following_user_id, :content_id, :created_at, :content_type, :content
  FEED_TYPE_MAP = {
    following_user_create_item: :item,
    following_user_stock_item:  :item,
    following_user_follow_user: :user,
  }.freeze # （細かいですが）定数はfreezeしていますね

  def initialize(following_user_id, feed_type, content_id, created_at)
    self.feed_type = feed_type.to_sym
    self.following_user_id = following_user_id
    self.content_type = FEED_TYPE_MAP[self.feed_type]
    self.content_id = content_id
    self.created_at = created_at
  end

  def content_item?
    content_type == :item
  end

  def content_user?
    content_type == :user
  end

  def self.of_user(user, page: nil, per: 10)
    following_user_ids = user.following_followships.pluck(:target_user_id)

    per_i = [per.to_i, 0].max
    page_i = [page.to_i, 1].max
    offset = per_i * page_i.pred

    feeds_sql = <<-SQL
      #{sql_following_user_create_item(following_user_ids)}
    UNION
      #{sql_following_user_stock_item(following_user_ids)}
    UNION
      #{sql_following_user_follow_user(following_user_ids)}
    SQL

    sql_result = ActiveRecord::Base.connection.select_all(<<-SQL)
      #{feeds_sql}
    ORDER BY
      created_at DESC
    LIMIT #{per_i} OFFSET #{offset}
    SQL

    total_count_result = ActiveRecord::Base.connection.select_all(<<-SQL)
    SELECT COUNT(*) AS count
    FROM (
      #{feeds_sql}
    ) AS feeds
    SQL
    total_count = total_count_result.to_hash.first['count'].to_i

    Kaminari.paginate_array(
      map_result(sql_result),
      total_count: total_count,
      limit: per_i,
      offset: offset
    )
  end

  private

  class << self
    def sql_following_user_create_item(user_ids)
      user_ids_text = user_ids.empty? ? "''" :  user_ids.join(', ')
      <<-SQL
        SELECT
          'following_user_create_item' AS feed_type, items.id AS content_id, items.created_at AS created_at, items.user_id AS following_user_id
        FROM
          items
        WHERE
          items.user_id IN (#{user_ids_text})
          AND items.published_at IS NOT NULL
      SQL
    end

    def sql_following_user_stock_item(user_ids)
      user_ids_text = user_ids.empty? ? "''" :  user_ids.join(', ')
      <<-SQL
        SELECT
          'following_user_stock_item' AS feed_type, items.id AS content_id, stocks.created_at AS created_at, stocks.user_id AS following_user_id
        FROM
          stocks
          INNER JOIN items ON items.id = stocks.item_id
        WHERE
          stocks.user_id IN (#{user_ids_text})
          AND items.published_at IS NOT NULL
      SQL
    end

    def sql_following_user_follow_user(user_ids)
      user_ids_text = user_ids.empty? ? "''" :  user_ids.join(', ')
      <<-SQL
        SELECT
          'following_user_follow_user' AS feed_type, followships.target_user_id AS content_id, followships.created_at AS created_at, followships.user_id AS following_user_id
        FROM
          followships
        WHERE
          followships.user_id IN (#{user_ids_text})
      SQL
    end

    def map_result(result)
      result.to_hash.map do |h|
        Feed.new(h['following_user_id'], h['feed_type'], h['content_id'], h['created_at'])
      end
    end
  end
end
