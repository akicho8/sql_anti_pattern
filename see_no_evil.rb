require "active_record"

class User < ActiveRecord::Base
end

User.count rescue $!            # => #<ActiveRecord::ConnectionNotEstablished: No connection pool with id primary found.>
User.count rescue 0             # => 0
