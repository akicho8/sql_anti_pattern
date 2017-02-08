require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name, :index => true
    t.timestamps    :index => true

    t.index [:name, :created_at, :updated_at]
  end
end

class User < ActiveRecord::Base
end

User.connection.indexes(User.table_name).each do |e|
  p [e.name, e.columns]
end

# >> ["index_users_on_name_and_created_at_and_updated_at", ["name", "created_at", "updated_at"]]
# >> ["index_users_on_updated_at", ["updated_at"]]
# >> ["index_users_on_created_at", ["created_at"]]
# >> ["index_users_on_name", ["name"]]
