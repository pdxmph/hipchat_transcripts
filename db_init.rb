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

ActiveRecord::Schema.define do
    create_table :people do |table|
        table.column :name, :string
    end

    create_table :rooms do |table|
        table.column :name, :string
        table.column :started, :date
        table.column :last_active, :date
        table.column :user_id, :integer
        table.column :privacy, :string
        table.column :message_count, :integer
    end
end
