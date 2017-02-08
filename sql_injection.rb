require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
  end
end

class User < ActiveRecord::Base
end

User.create!(:name => "alice")
User.create!(:name => "admin")

id = "1"
User.where("id = #{id}").take   # => #<User id: 1, name: "alice">

id = "0 or name = 'admin'"
User.where("id = #{id}").take   # => #<User id: 2, name: "admin">
