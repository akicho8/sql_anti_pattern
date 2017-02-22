require "active_record"

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false
ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
ActiveRecord::Base.connection.recreate_database("__test__")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.json :data
  end
end

class User < ActiveRecord::Base
end

user = User.create!(:data => {:foo => {:bar => 1}})
user.data                       # => {"foo"=>{"bar"=>1}}
User.where("JSON_EXTRACT(`data`, '$.foo.bar') >= 1").to_a # => [#<User id: 1, data: {"foo"=>{"bar"=>1}}>]
# >>    (5.2ms)  DROP DATABASE IF EXISTS `__test__`
# >>    (0.6ms)  CREATE DATABASE `__test__` DEFAULT CHARACTER SET `utf8`
# >>    (10.5ms)  CREATE TABLE `users` (`id` int AUTO_INCREMENT PRIMARY KEY, `data` json) ENGINE=InnoDB
# >>    (9.9ms)  CREATE TABLE `ar_internal_metadata` (`key` varchar(255) PRIMARY KEY, `value` varchar(255), `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL) ENGINE=InnoDB
# >>   ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  `ar_internal_metadata`.* FROM `ar_internal_metadata` WHERE `ar_internal_metadata`.`key` = 'environment' LIMIT 1
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `ar_internal_metadata` (`key`, `value`, `created_at`, `updated_at`) VALUES ('environment', 'default_env', '2017-02-23 05:33:50', '2017-02-23 05:33:50')
# >>    (0.5ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `users` (`data`) VALUES ('{\"foo\":{\"bar\":1}}')
# >>    (0.5ms)  COMMIT
# >>   User Load (0.3ms)  SELECT `users`.* FROM `users` WHERE (JSON_EXTRACT(`data`, '$.foo.bar') >= 1)
