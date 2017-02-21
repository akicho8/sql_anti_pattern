require "active_record"
require "rain_table"

ActiveRecord::Base.include(RainTable::ActiveRecord)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :users do |t|
  end
  create_table :comments do |t|
    t.belongs_to :commentable, polymorphic: true
  end
end

class User < ActiveRecord::Base
  has_many :comments, as: :commentable
end

# あらゆるレコードにコメントできるモデル
class Comment < ActiveRecord::Base
  has_many :comments, as: :commentable # 自分に対してもコメントできるようにするため
  belongs_to :commentable, polymorphic: true
end

user = User.create!             # => #<User id: 1>
comment = user.comments.create! # => #<Comment id: 1, commentable_type: "User", commentable_id: 1>
comment.comments.create!        # => #<Comment id: 2, commentable_type: "Comment", commentable_id: 1>
comment = user.comments.create! # => #<Comment id: 3, commentable_type: "User", commentable_id: 1>
comment.comments.create!        # => #<Comment id: 4, commentable_type: "Comment", commentable_id: 3>

tt Comment
# >> +----+------------------+----------------+
# >> | id | commentable_type | commentable_id |
# >> +----+------------------+----------------+
# >> |  1 | User             |              1 |
# >> |  2 | Comment          |              1 |
# >> |  3 | User             |              1 |
# >> |  4 | Comment          |              3 |
# >> +----+------------------+----------------+
