require "active_record"
require "org_tp"

logger = ActiveSupport::Logger.new(STDOUT)
ActiveRecord::Base.logger = logger
ActiveSupport::LogSubscriber.colorize_logging = false

ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  (2015...2020).each do |year|
    create_table "users_#{year}" do |t|
    end
  end
end

class User < ActiveRecord::Base
end

User.table_name = :users_2016
User.create!                    # => #<User id: 1>
User.table_name = :users_2017
User.create!                    # => #<User id: 1>
# >>    (0.1ms)  SELECT sqlite_version(*)
# >>    (0.3ms)  CREATE TABLE "users_2015" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)
# >>    (0.1ms)  CREATE TABLE "users_2016" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)
# >>    (0.1ms)  CREATE TABLE "users_2017" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)
# >>    (0.1ms)  CREATE TABLE "users_2018" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)
# >>    (0.1ms)  CREATE TABLE "users_2019" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)
# >>    (0.1ms)  CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL)
# >>   ActiveRecord::InternalMetadata Load (0.1ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = ? LIMIT ?  [["key", "environment"], ["LIMIT", 1]]
# >>    (0.1ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["key", "environment"], ["value", "default_env"], ["created_at", "2017-11-25 01:01:22.499038"], ["updated_at", "2017-11-25 01:01:22.499038"]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users_2016" DEFAULT VALUES
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users_2017" DEFAULT VALUES
# >>    (0.0ms)  commit transaction
