require "active_record"

logger = ActiveSupport::Logger.new(STDOUT)
ActiveRecord::Base.logger = logger
ActiveSupport::LogSubscriber.colorize_logging = false

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
ActiveRecord::Base.connection.recreate_database("__test__")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Schema.define do
  create_table :users do |t|
  end

  create_table :articles do |t|
    t.belongs_to :user, :foreign_key => true
  end
end

class User < ActiveRecord::Base
  has_many :articles
end

class Article < ActiveRecord::Base
  belongs_to :user
end

Article.create!(:user_id => 0) rescue $! # => #<ActiveRecord::InvalidForeignKey: Mysql2::Error: Cannot add or update a child row: a foreign key constraint fails (`__test__`.`articles`, CONSTRAINT `fk_rails_3d31dad1cc` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)): INSERT INTO `articles` (`user_id`) VALUES (0)>

# >>    (10.6ms)  DROP DATABASE IF EXISTS `__test__`
# >>    (0.4ms)  CREATE DATABASE `__test__` DEFAULT CHARACTER SET `utf8`
# >>    (11.8ms)  CREATE TABLE `users` (`id` int AUTO_INCREMENT PRIMARY KEY) ENGINE=InnoDB
# >>    (17.5ms)  CREATE TABLE `articles` (`id` int AUTO_INCREMENT PRIMARY KEY, `user_id` int,  INDEX `index_articles_on_user_id`  (`user_id`), CONSTRAINT `fk_rails_3d31dad1cc`
# >> FOREIGN KEY (`user_id`)
# >>   REFERENCES `users` (`id`)
# >> ) ENGINE=InnoDB
# >>    (11.0ms)  CREATE TABLE `ar_internal_metadata` (`key` varchar(255) PRIMARY KEY, `value` varchar(255), `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL) ENGINE=InnoDB
# >>   ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  `ar_internal_metadata`.* FROM `ar_internal_metadata` WHERE `ar_internal_metadata`.`key` = 'environment' LIMIT 1
# >>    (0.2ms)  BEGIN
# >>   SQL (0.3ms)  INSERT INTO `ar_internal_metadata` (`key`, `value`, `created_at`, `updated_at`) VALUES ('environment', 'default_env', '2017-02-15 13:34:59', '2017-02-15 13:34:59')
# >>    (0.6ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (2.5ms)  INSERT INTO `articles` (`user_id`) VALUES (0)
# >>    (0.9ms)  ROLLBACK
