# 例がいまいちだが、共通部分は v1, v2 の共通部分と考える

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

    create_table :foo_attrs do |t|
      t.belongs_to :user        # 共通部分
      t.integer :v1
    end

    create_table :bar_attrs do |t|
      t.belongs_to :user        # 共通部分
      t.string :v2
    end
  end
end

class User < ActiveRecord::Base
  has_many :foo_attrs
  has_many :bar_attrs
end

class FooAttr < ActiveRecord::Base
  belongs_to :user
end

class BarAttr < ActiveRecord::Base
  belongs_to :user
end

user = User.create!
user.foo_attrs.create!(:v1 => 1)   # => #<FooAttr id: 1, user_id: 1, v1: 1>
user.bar_attrs.create!(:v2 => "x") # => #<BarAttr id: 1, user_id: 1, v2: "x">
user.foo_attrs.to_a                # => [#<FooAttr id: 1, user_id: 1, v1: 1>]
user.bar_attrs.to_a                # => [#<BarAttr id: 1, user_id: 1, v2: "x">]
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users" DEFAULT VALUES
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "foo_attrs" ("user_id", "v1") VALUES (?, ?)  [["user_id", 1], ["v1", 1]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "bar_attrs" ("user_id", "v2") VALUES (?, ?)  [["user_id", 1], ["v2", "x"]]
# >>    (0.0ms)  commit transaction
# >>   FooAttr Load (0.1ms)  SELECT "foo_attrs".* FROM "foo_attrs" WHERE "foo_attrs"."user_id" = ?  [["user_id", 1]]
# >>   BarAttr Load (0.1ms)  SELECT "bar_attrs".* FROM "bar_attrs" WHERE "bar_attrs"."user_id" = ?  [["user_id", 1]]
