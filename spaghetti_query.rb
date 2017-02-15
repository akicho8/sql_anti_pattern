require "active_record"

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false
ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
# ActiveRecord::Base.connection.recreate_database("__test__")
# ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Base.logger.silence do
  ActiveRecord::Schema.define do
    create_table :users do |t|
      t.string :name
    end
    create_table :articles do |t|
      t.string :name
      t.integer :score
    end
    create_table :favorites do |t|
      t.belongs_to :user
      t.belongs_to :article
    end
  end

  class User < ActiveRecord::Base
    has_many :favorites
    has_many :articles, :through => :favorites
  end

  class Article < ActiveRecord::Base
    has_many :favorites
    has_many :users, :through => :favorites
  end

  class Favorite < ActiveRecord::Base
    belongs_to :user
    belongs_to :article
  end

  Article.create!(:name => "a")
  Article.create!(:name => "b")

  user = User.create!
  user.articles << Article.first
  user.articles << Article.second
end

def sql(s)
  ActiveRecord::Base.connection.select_all(s).collect(&:to_h)
end

# ダメな例
# ただ LEFT JOIN favorites f2 USING (user_id) をする意味がよくわからない
sql <<~EOT         # => [{"user_id"=>1, "count_a"=>2, "count_b"=>2}]
SELECT f1.user_id,
       COUNT(a1.id) AS count_a,
       COUNT(a2.id) AS count_b
FROM favorites f1
LEFT JOIN articles a1 ON (f1.article_id = a1.id AND a1.name = 'a')
LEFT JOIN favorites f2 USING (user_id)
LEFT JOIN articles a2 ON (f2.article_id = a2.id AND a2.name = 'b')
WHERE f1.user_id = 1
GROUP BY f1.user_id
EOT

# 分割
sql <<~EOT         # => [{"user_id"=>1, "count_a"=>1}]
SELECT f1.user_id, COUNT(a1.id) AS count_a
FROM favorites f1
LEFT JOIN articles a1 ON (f1.article_id = a1.id AND a1.name = 'a')
WHERE f1.user_id = 1
GROUP BY f1.user_id
EOT
sql <<~EOT         # => [{"user_id"=>1, "count_b"=>1}]
SELECT f2.user_id, COUNT(a2.id) AS count_b
FROM favorites f2
LEFT JOIN articles a2 ON (f2.article_id = a2.id AND a2.name = 'b')
WHERE f2.user_id = 1
GROUP BY f2.user_id
EOT

# これでいい気もするけど、読み間違えているのかもしれない
sql <<~EOT         # => [{"user_id"=>1, "count_a"=>1, "count_b"=>1}]
SELECT f1.user_id,
       COUNT(a1.id) AS count_a,
       COUNT(a2.id) AS count_b
FROM favorites f1
LEFT JOIN articles a1 ON (f1.article_id = a1.id AND a1.name = 'a')
LEFT JOIN articles a2 ON (f1.article_id = a2.id AND a2.name = 'b')
WHERE f1.user_id = 1
GROUP BY f1.user_id
EOT

Article.count                   # => 2
Favorite.count                  # => 2

# ダメな例
sql <<~EOT                      # => [{"user_id"=>1, "COUNT(f1.id)"=>4}]
SELECT f1.user_id, COUNT(f1.id) FROM favorites f1 LEFT JOIN favorites f2 USING (user_id) WHERE f1.user_id = 1 GROUP BY f1.user_id
EOT
# ダメな例
sql <<~EOT                      # => [{"COUNT(*)"=>4}]
SELECT COUNT(*) FROM favorites LEFT JOIN favorites USING (user_id)
EOT

################################################################################ JOIN で積算されていく

sql <<~EOT                      # => [{"COUNT(*)"=>2}]
SELECT COUNT(*) FROM favorites
EOT
sql <<~EOT                      # => [{"COUNT(*)"=>4}]
SELECT COUNT(*) FROM favorites
LEFT JOIN favorites USING (user_id)
EOT
sql <<~EOT                      # => [{"COUNT(*)"=>8}]
SELECT COUNT(*) FROM favorites
LEFT JOIN favorites USING (user_id)
LEFT JOIN favorites USING (user_id)
EOT
sql <<~EOT                      # => [{"COUNT(*)"=>16}]
SELECT COUNT(*) FROM favorites
LEFT JOIN favorites USING (user_id)
LEFT JOIN favorites USING (user_id)
LEFT JOIN favorites USING (user_id)
EOT

# >>    (0.1ms)  SELECT f1.user_id,
# >>        COUNT(a1.id) AS count_a,
# >>        COUNT(a2.id) AS count_b
# >> FROM favorites f1
# >> LEFT JOIN articles a1 ON (f1.article_id = a1.id AND a1.name = 'a')
# >> LEFT JOIN favorites f2 USING (user_id)
# >> LEFT JOIN articles a2 ON (f2.article_id = a2.id AND a2.name = 'b')
# >> WHERE f1.user_id = 1
# >> GROUP BY f1.user_id
# >> 
# >>    (0.1ms)  SELECT f1.user_id, COUNT(a1.id) AS count_a
# >> FROM favorites f1
# >> LEFT JOIN articles a1 ON (f1.article_id = a1.id AND a1.name = 'a')
# >> WHERE f1.user_id = 1
# >> GROUP BY f1.user_id
# >> 
# >>    (0.1ms)  SELECT f2.user_id, COUNT(a2.id) AS count_b
# >> FROM favorites f2
# >> LEFT JOIN articles a2 ON (f2.article_id = a2.id AND a2.name = 'b')
# >> WHERE f2.user_id = 1
# >> GROUP BY f2.user_id
# >> 
# >>    (0.1ms)  SELECT f1.user_id,
# >>        COUNT(a1.id) AS count_a,
# >>        COUNT(a2.id) AS count_b
# >> FROM favorites f1
# >> LEFT JOIN articles a1 ON (f1.article_id = a1.id AND a1.name = 'a')
# >> LEFT JOIN articles a2 ON (f1.article_id = a2.id AND a2.name = 'b')
# >> WHERE f1.user_id = 1
# >> GROUP BY f1.user_id
# >> 
# >>    (0.0ms)  SELECT COUNT(*) FROM "articles"
# >>    (0.0ms)  SELECT COUNT(*) FROM "favorites"
# >>    (0.1ms)  SELECT f1.user_id, COUNT(f1.id) FROM favorites f1 LEFT JOIN favorites f2 USING (user_id) WHERE f1.user_id = 1 GROUP BY f1.user_id
# >> 
# >>    (0.0ms)  SELECT COUNT(*) FROM favorites LEFT JOIN favorites USING (user_id)
# >> 
# >>    (0.0ms)  SELECT COUNT(*) FROM favorites
# >> 
# >>    (0.0ms)  SELECT COUNT(*) FROM favorites
# >> LEFT JOIN favorites USING (user_id)
# >> 
# >>    (0.0ms)  SELECT COUNT(*) FROM favorites
# >> LEFT JOIN favorites USING (user_id)
# >> LEFT JOIN favorites USING (user_id)
# >> 
# >>    (0.0ms)  SELECT COUNT(*) FROM favorites
# >> LEFT JOIN favorites USING (user_id)
# >> LEFT JOIN favorites USING (user_id)
# >> LEFT JOIN favorites USING (user_id)
# >> 
