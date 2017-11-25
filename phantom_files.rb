require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :file_path
  end
end

class User < ActiveRecord::Base
end

user = User.create!(:file_path => "path/to/file.png")
File.exist?(user.file_path) # => false
