#!/usr/bin/env ruby

require 'rubygems'
require 'tweetstream'
require 'meta-spotify'

require "config.rb"

# queuing
# now playing

$my_pwd = Dir.pwd

def play_track(uri)
  `open -a /Applications/Spotify.app #{uri}`
end

def play_pause
  `osascript #{$my_pwd}/play.applescript`
end

def skip
  `osascript #{$my_pwd}/next.applescript`
end

def vol(i)
  `osascript -e 'set volume #{i}'`
end

TweetStream::Daemon.new(TWITTER_USER, TWITTER_PASS).track(TWITTER_USER) do |status|
  txt = status.text.gsub /[@]{0,1}#{TWITTER_USER}/i, ''
  puts txt

  if txt.include?('!play') || txt.include?('!stop') || txt.include?('!start') || txt.include?('!pause')
    play_pause
  elsif txt.include?('!quiet')
    vol(4)
  elsif txt.include?('!loud')
    vol(7)
  elsif v = txt.match(/!vol ([0-9]{1,2})/)
    v = [11.0, v[1].to_i].min
    vol((v / 11.0) * 7.0)
  elsif txt.include?('!skip') || txt.include?('!next')
    skip
  else
    uri = txt.match(/(http:\/\/open\.spotify\.com\/[a-z]+\/[a-zA-Z0-9]+)/) || txt.match(/(spotify:[a-z]+:[a-zA-Z0-9]+)/)
    if !uri.nil?
      play_track(uri)
      return
    end

    # no urls or commands by now, try a search
    search = MetaSpotify::Track.search(txt)[:tracks]
    # find top result that's available in the uk
    search.each do |track|
      next if !track.album.available_territories.include?('gb') && !track.album.available_territories.include?('worldwide')
      play_track(track.uri)
      return
    end
  end
end
