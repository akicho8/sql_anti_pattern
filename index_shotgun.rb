require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
ActiveRecord::Base.connection.recreate_database("__test__")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Schema.define do
  create_table :articles do |t|
    t.string :name
    t.string :message
    t.timestamps

    t.index :id
    t.index :name
    t.index :message
    t.index [:message, :name]
    t.index [:id, :message, :name, :created_at, :updated_at], :unique => true, :name => :all
  end
end

class Article < ActiveRecord::Base
end

Article.connection.indexes(Article.table_name).each do |e|
  p [e.name, e.columns]
end

# >> ["all", ["id", "message", "name", "created_at", "updated_at"]]
# >> ["index_articles_on_id", ["id"]]
# >> ["index_articles_on_name", ["name"]]
# >> ["index_articles_on_message", ["message"]]
# >> ["index_articles_on_message_and_name", ["message", "name"]]
