require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :avatar1
    t.string :avatar2
    t.string :avatar3
  end
end

class User < ActiveRecord::Base
  def avatars
    [avatar1, avatar2, avatar3].compact
  end
end

user = User.create!(:avatar1 => "a", :avatar3 => "c")
user.avatars                # => ["a", "c"]
