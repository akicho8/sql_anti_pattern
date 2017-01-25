require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :friends_ids
  end
end

class User < ActiveRecord::Base
  def friends
    User.find(friends_ids.scan(/\d+/))
  end
end

user = User.create!
user.friends_ids = 2.times.collect { User.create!.id }.join(",")
user.friends_ids # => "2,3"
user.friends     # => [#<User id: 2, friends_ids: nil>, #<User id: 3, friends_ids: nil>]
