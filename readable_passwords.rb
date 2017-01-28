require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :password
  end
end

class User < ActiveRecord::Base
end

user = User.create!(:password => "password")
user.password_before_type_cast  # => "password"
