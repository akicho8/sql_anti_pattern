require "active_record"
ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.integer :age
  end
end

class User < ActiveRecord::Base
end

# null が入っているせいで年齢がでない
user = User.create!
"#{user.age}歳"                 # => "歳"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.integer :age, :null => false
  end
end

class User < ActiveRecord::Base
end

# NOT NULL 制約にしたのはいいけど NULL も許可したいのでかわりに -1 を入れる → なんの解決にもなってない
user = User.create!(:age => -1)
"#{user.age >= 0 ? user.age : "?"}歳" # => "?歳"

User.create!(:age => 20)

# むしろ余計に集計が面倒なことになった
User.average(:age).to_i                       # => 9
User.where.not(:age => -1).average(:age).to_i # => 20
