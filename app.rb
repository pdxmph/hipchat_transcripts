#!/usr/bin/env ruby

require 'json'
require 'sinatra'
require 'zip'
require 'haml'
require 'ostruct'

# Enable a rake kill task
File.open('.process.pid', 'w') {|f| f.write Process.pid }


config_file  = File.read('slack_config.json')
config = JSON.parse(config_file)

archive_uri = URI.parse(config["hipchat_archive_url"])
archive_filename = File.basename(archive_uri.path)
archive_dir_name = File.basename(archive_filename, ".tar.gz.aes")

set :export_root, config["hipchat_archive_location"] + "/#{archive_dir_name}"

users_file = File.read("#{settings.export_root}/users.json")
rooms_file = File.read("#{settings.export_root}/rooms.json")
set :rooms, JSON.parse(rooms_file)
set :users, JSON.parse(users_file)



# Where do we put the exports? 
archive_dir = File.dirname(__FILE__) + '/transcripts'

def room_messages(room_id) 
  room_file = File.read("#{settings.export_root}/rooms/#{room_id}/history.json")
  messages =  JSON.parse(room_file)
  messages.select! { |m| m["UserMessage"] }
  return messages
end

def find_rooms(room)
  @rooms_list = settings.rooms.select {|r| r["Room"]["name"].downcase.include?(room.downcase) }
  return @rooms_list
end

def get_room(room_id)
  room_obj = OpenStruct.new
  room = settings.rooms.detect { |r| r["Room"]["id"] == room_id }["Room"]
  room_obj.name = room["name"]
  room_obj.id = room["id"]
  return room_obj
end

# This is the route for search results
post "/rooms" do
  room = params[:room].downcase
  @rooms_list = settings.rooms.select {|r| r["Room"]["name"].downcase.include?(room) }
  haml :results, :layout => false
end


get '/' do
  haml :index
end

get '/markdown/:id' do
  # content_type 'text/plain;charset=utf8'
  room_id = params[:id]
  @room = get_room(params['id'].to_i)
  @messages = room_messages(room_id)
  if @messages.empty? 
    haml :empty_rooms
  else
    haml :markdown 
  end
end

get '/room/:id' do
  @room = get_room(params['id'].to_i)
  @messages = room_messages(params['id'])
  if @messages.empty?
    haml :empty_rooms
  else
    haml :room
  end
end


get '/archive/:id' do 
  room_id = params[:id].to_i
  room = get_room(room_id)
  messages = room_messages(room_id)
  md_template = File.read(File.dirname(__FILE__) + "/views/markdown.haml")
  html_template = File.read(File.dirname(__FILE__) + "/views/room.haml")
  transcript_file_name = room.name.gsub(/\W{1,}/, "_").downcase
  transcript_dir = File.dirname(__FILE__) + "/transcripts/#{transcript_file_name}"
  transcript_file = transcript_dir + "/#{transcript_file_name}"  
  transcript_zip_name = "#{transcript_dir}/#{transcript_file_name}_archive.zip"  


  FileUtils.mkdir_p(transcript_dir) unless File.directory?(transcript_dir)
    
  # Save the HTML template to a file
  output = Haml::Engine.new(html_template)
  html = output.render(Object.new, { :@room => room, :@messages => messages })
  html_file = transcript_file + "_transcript.html"
  (input_files ||= []) << html_file
  File.write(html_file, html)

  # Save the Markdown template to a file
  output = Haml::Engine.new(md_template)
  markdown = output.render(Object.new, { :@room => room, :@messages => messages })
  md_file = transcript_file + "_transcript.md"
  input_files << md_file
  File.write(md_file, markdown)
  
  zipfile_name = transcript_dir + "/#{@transcript_file_name}.zip"
  
  File.delete(zipfile_name) if File.exist?(zipfile_name)
  
  Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
    input_files.each do |filename|
      zipfile.add(File.basename(filename), File.join(transcript_dir, File.basename(filename)))
    end
  end
  
  send_file zipfile_name, :filename => transcript_zip_name, :type => 'Application/octet-stream'
  
  halt 200
end


