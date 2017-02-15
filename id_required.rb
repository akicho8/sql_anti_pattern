require "active_record"
require "rain_table"
ActiveRecord::Base.include(RainTable::ActiveRecord)

logger = ActiveSupport::Logger.new(STDOUT)
ActiveRecord::Base.logger = logger
ActiveSupport::LogSubscriber.colorize_logging = false

ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

logger.silence do
  ActiveRecord::Schema.define do
    create_table :users do |t|
    end

    create_table :profiles, :id => false do |t|
      t.belongs_to :user, :foreign_key => true # MySQL の場合 foreign_key 制約で Profile.create!(:user_id => 0) が通る心配を排除できる
    end
  end
end

class User < ActiveRecord::Base
  has_one :profile
end

class Profile < ActiveRecord::Base
  self.primary_key = :user_id

  belongs_to :user
end

user = User.create!                 # => #<User id: 1>
user.create_profile!(:user => user) # => #<Profile user_id: 1>

tt User
tt Profile

# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users" DEFAULT VALUES
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "profiles" ("user_id") VALUES (?)  [["user_id", 1]]
# >>    (0.0ms)  commit transaction
# >>   User Load (0.1ms)  SELECT "users".* FROM "users"
# >> +----+
# >> | id |
# >> +----+
# >> |  1 |
# >> +----+
# >>   Profile Load (0.0ms)  SELECT "profiles".* FROM "profiles"
# >> +---------+
# >> | user_id |
# >> +---------+
# >> |       1 |
# >> +---------+
