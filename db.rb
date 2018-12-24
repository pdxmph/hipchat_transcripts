#!/usr/bin/env ruby

require 'active_record'


ActiveRecord::Base.establish_connection(
:adapter => "sqlite3",
:database  => File.dirname(__FILE__) +  '/hc_rooms.sqlite3'
)


class User < ActiveRecord::Base
    has_many :rooms
end

class Room < ActiveRecord::Base
    belongs_to :user
end

