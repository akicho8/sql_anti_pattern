# 閉包テーブル
#
# ↓とてもわかりやすい
# http://www.slideshare.net/kamekoopa/ss-27728799

require "bundler/setup"
require "tree_support"
require "active_record"
require "org_tp"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :ships do |t|
    t.belongs_to :ancestor
    t.belongs_to :descendant
  end

  create_table :comments do |t|
    t.string :name
  end
end

# Comment のインターフェイスをこっちにもってくる手もある
class Ship < ActiveRecord::Base
  belongs_to :ancestor, :class_name => "Comment"
  belongs_to :descendant, :class_name => "Comment"
end

class Comment < ActiveRecord::Base
  def self.[](name)
    find_or_create_by!(:name => name)
  end

  def parent
    parents.last
  end

  def parents_and_self
    Ship.where(:descendant_id => id).collect(&:ancestor) # 順序に問題あり
  end

  def parents
    parents_and_self - [self]
  end

  def all_children_and_self
    Ship.where(:ancestor_id => id).collect(&:descendant)
  end

  def all_children
    all_children_and_self - [self]
  end

  # 逆に直下の子供だけを求めるのが難しい
  def children
    all_children                # ← 仮
  end

  # 本体
  # def ship
  #   Ship.find_by(:ancestor_id => id, :descendant_id => id)
  # end

  def add(name, &block)
    # 祖先を作る
    # スレッドが長くなるとここが大変な量になる。
    # 例えばコメント 999 と 1000 の書き込みで約2000レコードできる……というのは違うか
    # すべて>>1に対するレスだと考えるとそんな量でもない。
    parents_and_self.each do |e|
      Ship.create!(:ancestor => e, :descendant => Comment[name])
    end

    # parent と child が同じものを作り、これを「本体」とする
    # いや、これはよく考えればいらんレコードじゃないかな。なくても Comment クラス主体であれば綺麗に実装できるはず。
    Ship.create!(:ancestor => Comment[name], :descendant => Comment[name])

    if block_given?
      Comment[name].instance_eval(&block)
      self
    else
      Comment[name]
    end
  end
end

Ship.create!(:ancestor => Comment["A"], :descendant => Comment["A"])
Comment["A"].tap do |a|
  b = a.add("B")
  a.add("C")
  b.add("D")
end

# 全体
tp Ship.all.collect {|e| {"親" => e.ancestor.name, "子" => e.descendant.name} }
# Aの子孫
Comment["A"].all_children.collect(&:name).join        # => "BCD"
# Dの祖先
Comment["D"].parents.collect(&:name).join.reverse # => "BA"
# BにEを追加
Comment["B"].add("E")
# Eの先祖
Comment["E"].parents.collect(&:name).join.reverse # => "BA"
# Bの親
Comment["B"].parent             # => #<Comment id: 1, name: "A">
# Aの親
Comment["A"].parent             # => nil

Comment["A"].all_children.collect(&:name) # => ["B", "C", "D", "E"]
Comment["B"].all_children.collect(&:name) # => ["D", "E"]
Comment["C"].all_children.collect(&:name) # => []
Comment["D"].all_children.collect(&:name) # => []
Comment["E"].all_children.collect(&:name) # => []
Comment["A"].parent&.name                 # => nil
Comment["B"].parent&.name                 # => "A"
Comment["C"].parent&.name                 # => "A"
Comment["D"].parent&.name                 # => "B"
Comment["E"].parent&.name                 # => "B"

# children が「子孫」なので木がおかしい
puts TreeSupport.tree(Comment["A"])
# >> |----+----|
# >> | 親 | 子 |
# >> |----+----|
# >> | A  | A  |
# >> | A  | B  |
# >> | B  | B  |
# >> | A  | C  |
# >> | C  | C  |
# >> | A  | D  |
# >> | B  | D  |
# >> | D  | D  |
# >> |----+----|
# >> A
# >> ├─B
# >> │   ├─D
# >> │   └─E
# >> ├─C
# >> ├─D
# >> └─E
