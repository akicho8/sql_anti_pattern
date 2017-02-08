require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
  end
end

class User < ActiveRecord::Base
end

users = 4.times.collect { User.create! }
users.values_at(0, 2).collect(&:destroy!)

User.pluck(:id)                 # => [2, 4]

run = -> s { ActiveRecord::Base.connection.select_all(s).collect { |e| e.first.last } }
run.("SELECT id + 1 FROM users WHERE (id + 1) NOT IN (SELECT id FROM users)")                                              # => [3, 5]
run.("SELECT u1.id + 1 FROM USERS u1 LEFT OUTER JOIN users AS u2 ON u1.id + 1 = u2.id WHERE u2.id IS NULL ORDER BY u1.id") # => [3, 5]

# 1から埋めようとするならさらに面倒なことになる
id = ActiveRecord::Base.connection.select_value("SELECT id + 1 FROM users WHERE (id + 1) NOT IN (SELECT id FROM users) LIMIT 1")
id                              # => 3
User.create!(:id => id)         # => #<User id: 3>
User.pluck(:id)                 # => [2, 3, 4]
