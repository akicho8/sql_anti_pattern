require "active_record"

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.binary :bin, :size => 1024 * 1024
  end
end

class User < ActiveRecord::Base
end

3.times { User.create!(:bin => "x" * 1024 * 1024) }

require 'active_support/core_ext/benchmark'
Benchmark.ms { User.all.to_a         } # => 2.9799999902024865
Benchmark.ms { User.select(:id).to_a } # => 0.4229999613016844
Benchmark.ms { User.pluck(:id)       } # => 0.2049999893642962
# >>    (0.5ms)  CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "bin" blob)
# >>    (0.1ms)  CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL)
# >>   ActiveRecord::InternalMetadata Load (0.1ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = ? LIMIT ?  [["key", :environment], ["LIMIT", 1]]
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["key", "environment"], ["value", "default_env"], ["created_at", 2017-02-21 13:15:58 UTC], ["updated_at", 2017-02-21 13:15:58 UTC]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (1.7ms)  INSERT INTO "users" ("bin") VALUES (?)  [["bin", "<1048576 bytes of binary data>"]]
# >>    (0.0ms)  commit transaction
# >>    (0.1ms)  begin transaction
# >>   SQL (1.4ms)  INSERT INTO "users" ("bin") VALUES (?)  [["bin", "<1048576 bytes of binary data>"]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (1.3ms)  INSERT INTO "users" ("bin") VALUES (?)  [["bin", "<1048576 bytes of binary data>"]]
# >>    (0.1ms)  commit transaction
# >>   User Load (2.1ms)  SELECT "users".* FROM "users"
# >>   User Load (0.1ms)  SELECT "users"."id" FROM "users"
# >>    (0.0ms)  SELECT "users"."id" FROM "users"
