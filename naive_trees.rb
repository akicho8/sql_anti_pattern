require "bundler/setup"
require "tree_support"
require "active_record"
require "pp"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :comments do |t|
    t.belongs_to :parent
    t.string :name
  end
end

class Comment < ActiveRecord::Base
  belongs_to :parent, :class_name => name, :foreign_key => :parent_id
  has_many :children, :class_name => name, :foreign_key => :parent_id

  def add(name, &block)
    tap do
      child = children.create!(:name => name)
      if block_given?
        child.instance_eval(&block)
      end
    end
  end
end

root = Comment.create!(:name => "root").tap do |n|
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

puts TreeSupport.tree(root)
# >> root
# >> ├─a
# >> │   └─a1
# >> │       └─a2
# >> └─b
# >>     └─b1
# >>         └─b2
