require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
  end

  create_table :attrs do |t|
    t.belongs_to :user
    t.string :key
    t.integer :value
  end
end

class User < ActiveRecord::Base
  has_many :attrs
end

class Attr < ActiveRecord::Base
  belongs_to :user
end

user = User.create!
attr = user.attrs.create!(:key => :foo, :value => 1)   # => #<Attr id: 1, user_id: 1, key: "foo", value: 1>
attr.value                                             # => 1
attr = user.attrs.create!(:key => :bar, :value => "x") # => #<Attr id: 2, user_id: 1, key: "bar", value: 0>
attr.value                                             # => 0
# 数字しか入れられない
