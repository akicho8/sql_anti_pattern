require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :profile_image1
    t.string :profile_image2
    t.string :profile_image3
  end
end

class User < ActiveRecord::Base
end
