require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :articles do |t|
    t.string :comment1
    t.string :comment2
    t.string :comment3
  end
end

class Article < ActiveRecord::Base
  def comments
    [comment1, comment2, comment3].compact
  end
end

article = Article.create!(:comment1 => "a", :comment3 => "c")
article.comments                # => ["a", "c"]
