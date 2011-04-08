#!/usr/bin/env ruby

require 'rubygems'
require 'tweetstream'
require 'meta-spotify'

require "config.rb"

# volume control
# queuing
# now playing

def play_track(uri)
  puts "play #{uri}"
  `open -a /Applications/Spotify.app #{uri}`
end

def play_pause
  `osascript play.applescript`
end

def vol(i)
  `osascript -e 'set volume #{i}'`
end

TweetStream::Daemon.new(TWITTER_USER, TWITTER_PASS).track(TWITTER_USER) do |status|
  txt = status.text.gsub /[@]{0,1}#{TWITTER_USER}/, ''
  puts txt

  if txt.include?('!play') || txt.include?('!stop') || txt.include?('!start') || txt.include?('!pause')
    play_pause
    return
  end

  if txt.include?('!quiet')
    vol(3)
  end

  if txt.include?('!loud')
    vol(7)
  end

  uri = txt.match(/(http:\/\/open\.spotify\.com\/[a-z]+\/[a-zA-Z0-9]+)/) || txt.match(/(spotify:[a-z]+:[a-zA-Z0-9]+)/)
  if !uri.nil?
    play_track(uri)
    return
  end

  # no urls or commands by now, try a search
  search = MetaSpotify::Track.search(txt)[:tracks]
  # find top result that's available in the uk
  search.each do |track|
    next if track.album.available_territories.include?('gb')
    play_track(track.uri)
    return
  end
end