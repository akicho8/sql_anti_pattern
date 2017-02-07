require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false

ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
ActiveRecord::Base.connection.recreate_database("__test__")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.column :foo, "ENUM('a', 'b')"
  end
end

class User < ActiveRecord::Base
end

User.create!(:foo => "a") # => #<User id: 1, foo: "a">
User.create!(:foo => "b") # => #<User id: 2, foo: "b">
User.create!(:foo => "c") rescue $! # => #<ActiveRecord::StatementInvalid: Mysql2::Error: Data truncated for column 'foo' at row 1: INSERT INTO `users` (`foo`) VALUES ('c')>

# この挙動は気持ち悪い
User.create!(:foo => 0)   # => #<User id: 3, foo: "0">
User.create!(:foo => 1)   # => #<User id: 4, foo: "1">
User.create!(:foo => 2)   # => #<User id: 5, foo: "2">
User.create!(:foo => "0") # => #<User id: 6, foo: "0">
User.create!(:foo => "1") # => #<User id: 7, foo: "1">
User.create!(:foo => "2") # => #<User id: 8, foo: "2">

# >>    (5.0ms)  DROP DATABASE IF EXISTS `__test__`
# >>    (0.4ms)  CREATE DATABASE `__test__` DEFAULT CHARACTER SET `utf8`
# >>    (11.8ms)  CREATE TABLE `users` (`id` int AUTO_INCREMENT PRIMARY KEY, `foo` ENUM('a', 'b')) ENGINE=InnoDB
# >>    (10.5ms)  CREATE TABLE `ar_internal_metadata` (`key` varchar(255) PRIMARY KEY, `value` varchar(255), `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL) ENGINE=InnoDB
# >>   ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  `ar_internal_metadata`.* FROM `ar_internal_metadata` WHERE `ar_internal_metadata`.`key` = 'environment' LIMIT 1
# >>    (0.2ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `ar_internal_metadata` (`key`, `value`, `created_at`, `updated_at`) VALUES ('environment', 'default_env', '2017-02-06 13:26:35', '2017-02-06 13:26:35')
# >>    (0.5ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`foo`) VALUES ('a')
# >>    (0.5ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.3ms)  INSERT INTO `users` (`foo`) VALUES ('b')
# >>    (0.3ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`foo`) VALUES ('c')
# >>    (0.1ms)  ROLLBACK
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`foo`) VALUES ('0')
# >>    (0.4ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`foo`) VALUES ('1')
# >>    (0.3ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`foo`) VALUES ('2')
# >>    (0.6ms)  COMMIT
# >>    (0.2ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`foo`) VALUES ('0')
# >>    (0.4ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.1ms)  INSERT INTO `users` (`foo`) VALUES ('1')
# >>    (0.3ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`foo`) VALUES ('2')
# >>    (0.3ms)  COMMIT
