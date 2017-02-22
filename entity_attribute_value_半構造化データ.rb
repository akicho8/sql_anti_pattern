require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.text :data
  end
end

class User < ActiveRecord::Base
  store :data, accessors: [:foo, :bar], :coder => JSON
end

user = User.create!(foo: 1, bar: 2) # => #<User id: 1, data: {"foo"=>1, "bar"=>2}>
user.foo                            # => 1
user.bar                            # => 2
user.data_before_type_cast          # => "{\"foo\":1,\"bar\":2}"
user.data                           # => {"foo"=>1, "bar"=>2}
