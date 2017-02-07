require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "mysql2", host: "127.0.0.1")
ActiveRecord::Base.connection.recreate_database("__test__")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(database: "__test__"))

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.column :c1, :float
    t.column :c2, :double
    t.column :c3, "DECIMAL(65, 30)"
  end
end

class User < ActiveRecord::Base
end

v = 5.5555555555555555555555555555555555555
user = User.create!(:c1 => v, :c2 => v, :c3 => v).reload
user.c1.to_d # => 0.555556e1
user.c2.to_d # => 0.555555555555556e1
user.c3.to_d # => 0.5555555555555555e1
