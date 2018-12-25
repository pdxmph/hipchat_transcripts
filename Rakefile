# Use the slack_config.json file! No user serviceable parts below here! 

require 'open-uri'
require 'uri'
require 'json'

config_file  = File.read('slack_config.json')
config = JSON.parse(config_file)
archive_uri = URI.parse(config["hipchat_archive_url"])
archive_filename = File.basename(archive_uri.path)
archive_dir_name = File.basename(archive_filename, ".tar.gz.aes")

desc "Run the app in an interactive console."
task :console do
  app = File.dirname(__FILE__) + '/app.rb'
  sh "bundle exec irb -r #{app}"
end

desc "Run the app at http://localhost:4567 "
task :run do 
  app = File.dirname(__FILE__) + '/app.rb'
  puts "\n\n\nGo to http://localhost:4567 in your browser. ^c to exit. \n\n\n"
  `bundle exec nohup #{app} -p 4567  >> /dev/null`
end


desc "Download the latest HipChat archive."
task :download_archive do 
    
  puts "Downloading the latest HipChat archive (this'll take a while ...)"
  download_loc = config["hipchat_archive_location"] + "/" + config["hipchat_archive_name"]
    
  File.open(download_loc , "wb") do |saved_file|
    open(config["hipchat_archive_url"], "rb") do |read_file|
      saved_file.write(read_file.read)
    end
  end
end

desc "Clean out the sandbox and unpack the archive."
task :unpack do
  
  puts "Cleaning out the sandbox and unpacking a fresh copy ..."
  tarball = "#{config["hipchat_archive_location"]}/#{config["tarball_name"]}"
  archive_dir = "#{config["hipchat_archive_location"]}/#{archive_dir_name}"
  
  `openssl aes-256-cbc -d -in #{config["hipchat_archive_location"]}/#{config["hipchat_archive_name"]} -out #{config["hipchat_archive_location"]}/#{config["tarball_name"]} -pass pass:#{config["hipchat_archive_password"]}`
  `rm -rf #{archive_dir}`
  `mkdir #{archive_dir}`
  `tar xzf #{tarball} -C #{archive_dir}`
  
end


