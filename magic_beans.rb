require "active_record"
require "nkf"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
  end
end

class User < ActiveRecord::Base
end

# controller
params = {:name => "さかもとりょうま"}

user = User.new
user.name = NKF::nkf("--katakana -w", params[:name])
user.save!
user                    # => #<User id: 1, name: "サカモトリョウマ">
