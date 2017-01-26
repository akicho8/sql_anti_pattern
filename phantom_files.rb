require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :profile_image_path
  end
end

class User < ActiveRecord::Base
end

user = User.create!(:profile_image_path => "path/to/profile.png") # => #<User id: 1, profile_image_path: "path/to/profile.png">
Pathname(user.profile_image_path).exist?                          # => false
