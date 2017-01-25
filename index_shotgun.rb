require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
ActiveRecord::Base.connection.recreate_database("__test__")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Schema.define do
  create_table :articles do |t|
    t.string :title
    t.string :message
    t.timestamps

    t.index :id
    t.index :title
    t.index :message
    t.index :created_at
    t.index :updated_at
    t.index [:title, :message]
    t.index [:id, :title, :message, :created_at, :updated_at], :unique => true, :name => :all
  end
end

class Article < ActiveRecord::Base
end

Article.connection.indexes(Article.table_name).each do |e|
  p [e.name, e.columns]
end

# >> ["all", ["id", "title", "message", "created_at", "updated_at"]]
# >> ["index_articles_on_id", ["id"]]
# >> ["index_articles_on_title", ["title"]]
# >> ["index_articles_on_message", ["message"]]
# >> ["index_articles_on_created_at", ["created_at"]]
# >> ["index_articles_on_updated_at", ["updated_at"]]
# >> ["index_articles_on_title_and_message", ["title", "message"]]
