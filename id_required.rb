require "active_record"

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
  end

  create_table :profiles, :primary_key => :user_id do |t|
  end
end

class User < ActiveRecord::Base
  has_one :profile
end

class Profile < ActiveRecord::Base
  primary_key                   # => "user_id"
end

user = User.create!             # => #<User id: 1>
user.create_profile!            # => #<Profile user_id: 1>
# >>    (0.4ms)  CREATE TABLE "profiles" ("user_id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)
# >>    (0.1ms)  CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL)
# >>   ActiveRecord::InternalMetadata Load (0.1ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = ? LIMIT ?  [["key", :environment], ["LIMIT", 1]]
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["key", "environment"], ["value", "default_env"], ["created_at", 2017-02-09 06:27:36 UTC], ["updated_at", 2017-02-09 06:27:36 UTC]]
# >>    (0.0ms)  commit transaction
# >>    (0.1ms)  CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users" DEFAULT VALUES
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "profiles" DEFAULT VALUES
# >>    (0.0ms)  commit transaction
# >>   Profile Load (0.1ms)  SELECT  "profiles".* FROM "profiles" WHERE "profiles"."user_id" = ? LIMIT ?  [["user_id", 1], ["LIMIT", 1]]
