require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :favorites_ids
  end
  create_table :books do |t|
  end
end

class User < ActiveRecord::Base
  def favorites
    Book.find(favorites_ids.scan(/\d+/))
  end
end

class Book < ActiveRecord::Base
end

user = User.create!
user.favorites_ids = 2.times.collect { Book.create!.id }.join(",")
user.favorites_ids              # => "1,2"
user.favorites                  # => [#<Book id: 1>, #<Book id: 2>]
