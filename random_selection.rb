require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
  end
end

class User < ActiveRecord::Base
end

2.times { User.create! }

User.order("random()").take        # => #<User id: 1>
User.offset(rand(User.count)).take # => #<User id: 2>
