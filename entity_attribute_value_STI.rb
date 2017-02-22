require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
  end

  create_table :attrs do |t|
    t.belongs_to :user
    t.string :type
    t.integer :v1
    t.string :v2
  end
end

class User < ActiveRecord::Base
  has_many :attrs
  has_one :foo
  has_one :bar
end

class Attr < ActiveRecord::Base
  belongs_to :user
end

class Foo < Attr
end

class Bar < Attr
end

user = User.create!
user.create_foo!(:v1 => 1)   # => #<Foo id: 1, user_id: 1, type: "Foo", v1: 1, v2: nil>
user.create_bar!(:v2 => "x") # => #<Bar id: 2, user_id: 1, type: "Bar", v1: nil, v2: "x">
