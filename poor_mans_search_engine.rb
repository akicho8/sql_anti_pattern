require "active_record"
require "pp"

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false
ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
ActiveRecord::Base.connection.recreate_database("__test__")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Schema.define do
  create_table :articles do |t|
    t.string :body, :index => true
  end
end

class Article < ActiveRecord::Base
end

Article.create!(:body => "日本")
Article.create!(:body => "日本語")

# これでは限界がくる
Article.where(["body like ?", "%日本%"]).to_a               # => [#<Article id: 1, body: "日本">, #<Article id: 2, body: "日本語">]
Article.where(["body regexp ?", "[[:<:]]日本[[:>:]]"]).to_a # => [#<Article id: 1, body: "日本">]
puts Article.where(:id => 1).explain
puts Article.where(["body like ?", "%日本%"]).explain

# 全文検索
ActiveRecord::Base.connection.select_one("show variables like 'innodb_ft_min_token_size'") # => {"Variable_name"=>"innodb_ft_min_token_size", "Value"=>"1"}
ActiveRecord::Base.connection.execute("ALTER TABLE articles ADD FULLTEXT(body)")

Article.where("MATCH(body) AGAINST ('日本' IN BOOLEAN MODE)").to_a # => [#<Article id: 1, body: "日本">]
# >>    (6.8ms)  DROP DATABASE IF EXISTS `__test__`
# >>    (0.5ms)  CREATE DATABASE `__test__` DEFAULT CHARACTER SET `utf8`
# >>    (12.1ms)  CREATE TABLE `articles` (`id` int AUTO_INCREMENT PRIMARY KEY, `body` varchar(255),  INDEX `index_articles_on_body`  (`body`)) ENGINE=InnoDB
# >>    (11.3ms)  CREATE TABLE `ar_internal_metadata` (`key` varchar(255) PRIMARY KEY, `value` varchar(255), `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL) ENGINE=InnoDB
# >>   ActiveRecord::InternalMetadata Load (0.2ms)  SELECT  `ar_internal_metadata`.* FROM `ar_internal_metadata` WHERE `ar_internal_metadata`.`key` = 'environment' LIMIT 1
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `ar_internal_metadata` (`key`, `value`, `created_at`, `updated_at`) VALUES ('environment', 'default_env', '2017-02-15 13:35:08', '2017-02-15 13:35:08')
# >>    (0.5ms)  COMMIT
# >>    (0.1ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `articles` (`body`) VALUES ('日本')
# >>    (0.5ms)  COMMIT
# >>    (0.2ms)  BEGIN
# >>   SQL (0.2ms)  INSERT INTO `articles` (`body`) VALUES ('日本語')
# >>    (0.3ms)  COMMIT
# >>   Article Load (0.7ms)  SELECT `articles`.* FROM `articles` WHERE (body like '%日本%')
# >>   Article Load (0.9ms)  SELECT `articles`.* FROM `articles` WHERE (body regexp '[[:<:]]日本[[:>:]]')
# >>   Article Load (0.4ms)  SELECT `articles`.* FROM `articles` WHERE `articles`.`id` = 1
# >> EXPLAIN for: SELECT `articles`.* FROM `articles` WHERE `articles`.`id` = 1
# >> +----+-------------+----------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
# >> | id | select_type | table    | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
# >> +----+-------------+----------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
# >> |  1 | SIMPLE      | articles | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |    100.0 | NULL  |
# >> +----+-------------+----------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
# >> 1 row in set (0.00 sec)
# >>   Article Load (0.4ms)  SELECT `articles`.* FROM `articles` WHERE (body like '%日本%')
# >> EXPLAIN for: SELECT `articles`.* FROM `articles` WHERE (body like '%日本%')
# >> +----+-------------+----------+------------+-------+---------------+------------------------+---------+------+------+----------+--------------------------+
# >> | id | select_type | table    | partitions | type  | possible_keys | key                    | key_len | ref  | rows | filtered | Extra                    |
# >> +----+-------------+----------+------------+-------+---------------+------------------------+---------+------+------+----------+--------------------------+
# >> |  1 | SIMPLE      | articles | NULL       | index | NULL          | index_articles_on_body | 768     | NULL |    2 |     50.0 | Using where; Using index |
# >> +----+-------------+----------+------------+-------+---------------+------------------------+---------+------+------+----------+--------------------------+
# >> 1 row in set (0.00 sec)
# >>    (10.1ms)  show variables like 'innodb_ft_min_token_size'
# >>    (118.3ms)  ALTER TABLE articles ADD FULLTEXT(body)
# >>   Article Load (1.7ms)  SELECT `articles`.* FROM `articles` WHERE (MATCH(body) AGAINST ('日本' IN BOOLEAN MODE))
