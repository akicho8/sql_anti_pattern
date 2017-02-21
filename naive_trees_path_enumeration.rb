# 経路列挙

require "bundler/setup"
require "tree_support"
require "active_record"
require "rain_table"

ActiveRecord::Base.include(RainTable::ActiveRecord)

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :comments do |t|
    t.belongs_to :parent
    t.string :name
    t.string :path
  end
end

class Comment < ActiveRecord::Base
  belongs_to :parent, :class_name => name, :foreign_key => :parent_id
  has_many :children, :class_name => name, :foreign_key => :parent_id

  def add(name, &block)
    tap do
      child = children.create!(:name => name)
      child.update!(:path => "#{path}#{child.id}/")
      if block_given?
        child.instance_eval(&block)
      end
    end
  end
end

root = Comment.create!(:name => "root").tap do |n|
  n.update!(:path => "#{n.id}/")
  n.instance_eval do
    add "a" do
      add "a1" do
        add "a2"
      end
    end
    add "b" do
      add "b1" do
        add "b2"
      end
    end
  end
end

tt Comment
puts TreeSupport.tree(root)

# 1回のSQLで2に結びつくレコードを取得できる
tt Comment.where(["path like ?", "1/2/%"])
# >> +----+-----------+------+----------+
# >> | id | parent_id | name | path     |
# >> +----+-----------+------+----------+
# >> |  1 |           | root | 1/       |
# >> |  2 |         1 | a    | 1/2/     |
# >> |  3 |         2 | a1   | 1/2/3/   |
# >> |  4 |         3 | a2   | 1/2/3/4/ |
# >> |  5 |         1 | b    | 1/5/     |
# >> |  6 |         5 | b1   | 1/5/6/   |
# >> |  7 |         6 | b2   | 1/5/6/7/ |
# >> +----+-----------+------+----------+
# >> root
# >> ├─a
# >> │   └─a1
# >> │       └─a2
# >> └─b
# >>     └─b1
# >>         └─b2
# >> +----+-----------+------+----------+
# >> | id | parent_id | name | path     |
# >> +----+-----------+------+----------+
# >> |  2 |         1 | a    | 1/2/     |
# >> |  3 |         2 | a1   | 1/2/3/   |
# >> |  4 |         3 | a2   | 1/2/3/4/ |
# >> +----+-----------+------+----------+
