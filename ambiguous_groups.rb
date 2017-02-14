require "active_record"

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false
ActiveRecord::Migration.verbose = false

def sql(s)
  ActiveRecord::Base.connection.select_all(s).collect(&:to_h) rescue $!
end

######################################## SQLite3

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.integer :score
  end
end

class User < ActiveRecord::Base
end

User.create!(:name => "a", :score => 1)
User.create!(:name => "a", :score => 2)
User.create!(:name => "b", :score => 3)
User.create!(:name => "b", :score => 4)

sql "SELECT name, AVG(score) FROM users GROUP BY name" # => [{"name"=>"a", "AVG(score)"=>1.5}, {"name"=>"b", "AVG(score)"=>3.5}]
sql "SELECT   id, AVG(score) FROM users GROUP BY name" # => [{"id"=>2, "AVG(score)"=>1.5}, {"id"=>4, "AVG(score)"=>3.5}]

######################################## MySQL

ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
ActiveRecord::Base.connection.recreate_database("__test__")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.integer :score
  end
end

class User < ActiveRecord::Base
end

User.create!(:name => "a", :score => 1)
User.create!(:name => "a", :score => 2)
User.create!(:name => "b", :score => 3)
User.create!(:name => "b", :score => 4)
sql "SELECT name, AVG(score) FROM users GROUP BY name" # => [{"name"=>"a", "AVG(score)"=>0.15e1}, {"name"=>"b", "AVG(score)"=>0.35e1}]
sql "SELECT   id, AVG(score) FROM users GROUP BY name" # => #<ActiveRecord::StatementInvalid: Mysql2::Error: Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column '__test__.users.id' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by: SELECT   id, AVG(score) FROM users GROUP BY name>
# >>    (0.5ms)  CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "score" integer)
# >>    (0.1ms)  CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL)
# >>   ActiveRecord::InternalMetadata Load (0.1ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = ? LIMIT ?  [["key", :environment], ["LIMIT", 1]]
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["key", "environment"], ["value", "default_env"], ["created_at", 2017-02-14 02:35:49 UTC], ["updated_at", 2017-02-14 02:35:49 UTC]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "users" ("name", "score") VALUES (?, ?)  [["name", "a"], ["score", 1]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users" ("name", "score") VALUES (?, ?)  [["name", "a"], ["score", 2]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users" ("name", "score") VALUES (?, ?)  [["name", "b"], ["score", 3]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users" ("name", "score") VALUES (?, ?)  [["name", "b"], ["score", 4]]
# >>    (0.0ms)  commit transaction
# >>    (0.1ms)  SELECT name, AVG(score) FROM users GROUP BY name
# >>    (0.1ms)  SELECT   id, AVG(score) FROM users GROUP BY name
# >>    (6.3ms)  DROP DATABASE IF EXISTS `__test__`
# >>    (0.6ms)  CREATE DATABASE `__test__` DEFAULT CHARACTER SET `utf8`
# >>    (13.0ms)  CREATE TABLE `users` (`id` int AUTO_INCREMENT PRIMARY KEY, `name` varchar(255), `score` int) ENGINE=InnoDB
# >>    (10.0ms)  CREATE TABLE `ar_internal_metadata` (`key` varchar(255) PRIMARY KEY, `value` varchar(255), `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL) ENGINE=InnoDB
# >>   ActiveRecord::InternalMetadata Load (0.5ms)  SELECT  `ar_internal_metadata`.* FROM `ar_internal_metadata` WHERE `ar_internal_metadata`.`key` = 'environment' LIMIT 1
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `ar_internal_metadata` (`key`, `value`, `created_at`, `updated_at`) VALUES ('environment', 'default_env', '2017-02-14 02:35:49.658273', '2017-02-14 02:35:49.658273')
# >>    (0.5ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.4ms)  INSERT INTO `users` (`name`, `score`) VALUES ('a', 1)
# >>    (0.4ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`name`, `score`) VALUES ('a', 2)
# >>    (0.5ms)  COMMIT
# >>    (0.2ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`name`, `score`) VALUES ('b', 3)
# >>    (0.4ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`name`, `score`) VALUES ('b', 4)
# >>    (0.4ms)  COMMIT
# >>    (0.3ms)  SELECT name, AVG(score) FROM users GROUP BY name
# >>    (0.5ms)  SELECT   id, AVG(score) FROM users GROUP BY name
