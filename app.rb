#!/usr/bin/env ruby

require 'json'
require 'sinatra'
require File.dirname(__FILE__) + '/db'
require 'zip'
require 'haml'

users_file = File.read("hipchat_export/users.json")
rooms_file = File.read("hipchat_export/rooms.json")
archive_dir = File.dirname(__FILE__) + '/transcripts'


def room_messages(room_id) 
  room_file = File.read("hipchat_export/rooms/#{room_id}/history.json")
  messages =  JSON.parse(room_file)
  messages.select! { |m| m["UserMessage"] }
  return messages
end

get '/' do
  haml :index
end

get '/markdown/:id' do
  content_type 'text/plain;charset=utf8'
  room_id = params[:id]
  @room = Room.find(room_id)
  @messages = room_messages(room_id)
  if @messages.empty? 
    haml :empty_rooms
  else
    haml :markdown 
  end
end

get '/room/:id' do
  room_id = params[:id]
  @room = Room.find(room_id)
  @messages = room_messages(room_id)

  if @messages.empty?
    haml :empty_rooms
  else
    haml :room
  end

end


get '/archive/:id' do 
  room_id = params[:id]
  room = Room.find(room_id)  
  messages = room_messages(room_id)
  md_template = File.read(File.dirname(__FILE__) + "/views/markdown.haml")
  html_template = File.read(File.dirname(__FILE__) + "/views/room.haml")
  transcript_file_name = room.name.gsub(/\W{1,}/, "_").downcase
  transcript_dir = File.dirname(__FILE__) + "/transcripts/#{transcript_file_name}"
  transcript_file = transcript_dir + "/#{transcript_file_name}"  
  transcript_zip_name = "#{transcript_dir}/#{transcript_file_name}_archive.zip"  


  Dir.mkdir(transcript_dir) unless File.directory?(transcript_dir)
    
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

post "/rooms" do
  room = params[:room]
  find_rooms(room).to_json
  haml :results, :layout => false
end





def find_rooms(room)
    @rooms =  Room.where("name LIKE ?", "%#{room}%")
    @rooms
end