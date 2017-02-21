# 入れ子集合

require "bundler/setup"
require "tree_support"
require "active_record"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :comments do |t|
    t.belongs_to :parent
    t.integer :left
    t.integer :right
    t.string :name
  end
end

class Comment < ActiveRecord::Base
  belongs_to :parent, :class_name => name, :foreign_key => :parent_id
  has_many :children, :class_name => name, :foreign_key => :parent_id

  def self.[](name)
    find_or_create_by!(:name => name)
  end

  def add(name, &block)
    current = children.create!(:name => name)
    if block_given?
      current.instance_eval(&block)
    end
    current
  end

  def to_s_tree_name
    "[#{id}#{name}] #{left}:#{right}"
  end
end

@root = Comment[:A].tap do |a|
  b = a.add(:B)
  a.add(:C)
  b.add(:D)
end

def renum(e, v)
  e.update!(:left => v)
  e.children.each { |e|
    v = renum(e, v + 1)
  }
  v += 1
  e.update!(:right => v)
  v
end

# 左右の値を埋めていく
renum(@root, 1)
puts TreeSupport.tree(@root.reload)

# これで簡単に引けるようになる
# 1 の子孫 自分含む   は L が 1      から 8
# 1 の子孫 自分含まず は L が 1.next から 8
# 2 の子孫 自分含む   は L が 2      から 5
Comment.where(:left => 1..8).collect(&:name)      # => ["A", "B", "C", "D"]
Comment.where(:left => 1.next..8).collect(&:name) # => ["B", "C", "D"]
Comment.where(:left => 2..5).collect(&:name)      # => ["B", "D"]

# 4 の先祖 (L..R).include?(3)
Comment.where(["left <= ? AND ? <= right", 3, 3]).collect(&:name).reverse # => ["D", "B", "A"]
# 4 の祖先 自分含まず (あってる？)
Comment.where(["left <= ? AND ? <= right", 2, 2]).collect(&:name).reverse # => ["B", "A"]

puts TreeSupport.tree(@root.reload)

# B の下に E を追加
Comment[:B].add(:E)

# この状態だと確認してみると左右の値が入ってないことがわかる
puts TreeSupport.tree(@root.reload)

# なので再計算する。このコストが高い
renum(@root, 1)
puts TreeSupport.tree(@root.reload)

# B の子孫 (自分を含む)
Comment.where(:left => 2..7).collect(&:name).reverse # => ["E", "D", "B"]
# >> [1A] 1:8
# >> ├─[2B] 2:5
# >> │   └─[4D] 3:4
# >> └─[3C] 6:7
# >> [1A] 1:8
# >> ├─[2B] 2:5
# >> │   └─[4D] 3:4
# >> └─[3C] 6:7
# >> [1A] 1:8
# >> ├─[2B] 2:5
# >> │   ├─[4D] 3:4
# >> │   └─[5E] :
# >> └─[3C] 6:7
# >> [1A] 1:10
# >> ├─[2B] 2:7
# >> │   ├─[4D] 3:4
# >> │   └─[5E] 5:6
# >> └─[3C] 8:9
