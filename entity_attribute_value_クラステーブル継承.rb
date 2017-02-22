require "active_record"

ActiveRecord::Base.logger = nil
ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Base.logger.silence do
  ActiveRecord::Schema.define do
    create_table :users do |t|
    end

    create_table :attrs do |t|
      t.belongs_to :user
    end

    create_table :foo_attrs do |t|
      t.belongs_to :attr
      t.integer :v1
    end

    create_table :bar_attrs do |t|
      t.belongs_to :attr
      t.string :v2
    end
  end
end

class User < ActiveRecord::Base
  has_many :attrs
  has_many :foo_attrs, :through => :attrs, :source => :foo_attrs
  has_many :bar_attrs, :through => :attrs, :source => :bar_attrs
end

class Attr < ActiveRecord::Base
  belongs_to :user
  has_many :foo_attrs
  has_many :bar_attrs
end

class FooAttr < ActiveRecord::Base
  belongs_to :attr
end

class BarAttr < ActiveRecord::Base
  belongs_to :attr
end

user = User.create!
user.attrs.create! { |e| e.foo_attrs.build(:v1 => 1)   } # => #<Attr id: 1, user_id: 1>
user.attrs.create! { |e| e.bar_attrs.build(:v2 => "x") } # => #<Attr id: 2, user_id: 1>
user.foo_attrs.to_a                                      # => [#<FooAttr id: 1, attr_id: 1, v1: 1>]
user.bar_attrs.to_a                                      # => [#<BarAttr id: 1, attr_id: 2, v2: "x">]
user.attrs.to_a                                          # => [#<Attr id: 1, user_id: 1>, #<Attr id: 2, user_id: 1>]

# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users" DEFAULT VALUES
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "attrs" ("user_id") VALUES (?)  [["user_id", 1]]
# >>   SQL (0.0ms)  INSERT INTO "foo_attrs" ("attr_id", "v1") VALUES (?, ?)  [["attr_id", 1], ["v1", 1]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "attrs" ("user_id") VALUES (?)  [["user_id", 1]]
# >>   SQL (0.0ms)  INSERT INTO "bar_attrs" ("attr_id", "v2") VALUES (?, ?)  [["attr_id", 2], ["v2", "x"]]
# >>    (0.0ms)  commit transaction
# >>   FooAttr Load (0.1ms)  SELECT "foo_attrs".* FROM "foo_attrs" INNER JOIN "attrs" ON "foo_attrs"."attr_id" = "attrs"."id" WHERE "attrs"."user_id" = ?  [["user_id", 1]]
# >>   BarAttr Load (0.1ms)  SELECT "bar_attrs".* FROM "bar_attrs" INNER JOIN "attrs" ON "bar_attrs"."attr_id" = "attrs"."id" WHERE "attrs"."user_id" = ?  [["user_id", 1]]
# >>   Attr Load (0.1ms)  SELECT "attrs".* FROM "attrs" WHERE "attrs"."user_id" = ?  [["user_id", 1]]
