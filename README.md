# HipChat Transcript Generator

<img width="800" alt="HipChat transcripterator" src="https://user-images.githubusercontent.com/283428/50415376-7d1a2180-07cf-11e9-8c22-5f3b9ea254ef.png">

This is a small, dumb Sinatra app that:

1. Automates the process of downloading and unpacking a HipChat archive from the HipChat admin console. 
2. Provides a web GUI for finding HipChat rooms by name and looking at their transcripts. 
3. Provides a means to produce a zip file that contains a Markdown and HTML copy of the transcript. 

It's meant to help IT teams make human-readable transcripts of HipChat room archives. Its archives exclude everything but user messages (so you won't have a record of notifications, just human and bot messages.)

It does everything in memory (no database backend). All you need is to point it at an unpacked HipChat archive in the config file and run it. 

## Setting it up

1. Clone the repo
2. `cd` into the repo and run `bundle install`
2. Make a downloadable archive of your HipChat data in the HipChat admin console. Note the password and get the URL when it's done. 
3. Make a directory where you want your archives to be unpacked. 
4. Copy the `slack_config.json.example` to `slack_config.json` and edit it: 

  * `hipchat_archive_url`: The link to your HipChat archive
  * `hipchat_archive_location`: The path to your HipChat archive (no trailing slash)
  * `hipchat_archive_name`: e.g. `hipchat-28367-2018-12-19_13-49-30.tar.gz.aes`
  * `tarball_name`:  e.g. `hipchat-28367-2018-12-19_13-49-30.tar.gz`

Once you've configured all that, you should be able to:

1. `rake download_archive` to download your archive
2. `rake unpack` to decrypt the archive from the command line
3. `rake run` to start the app. Visit it at `http://localhost:4567`

## Using the app

1. Visit `http://localhost:4567`
2. Search for a room. Just type a room name (or fragment of a room name) in the search field and hit the enter key. 
3. To look at the HTML transcript, click the room name in the results. 
4. To look at the Markdown transcript, click the `Markdown` button. 
5. To download a zip file of the HTML and Markdown transcripts, click the `Zip` button. 


## ToDo

* Make a Google Doc of a given transcript. 
* Upload a transcript zip to Google Drive. 