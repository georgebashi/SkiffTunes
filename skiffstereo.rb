#!/usr/bin/env ruby

require 'rubygems'
require 'tweetstream'

require "config.rb"

TweetStream::Daemon.new(TWITTER_USER, TWITTER_PASS).track(TWITTER_USER) do |status|
  txt = status.text.gsub /@test_gb/, ''

  if txt.include?('!play') || txt.include?('!stop') || txt.include?('!start') || txt.include?('!pause')
    `osascript play.applescript`
  end

  url = txt.match(/(http:\/\/open\.spotify\.com\/[a-z]+\/[a-zA-Z0-9]+)/) || txt.match(/(spotify:[a-z]+:[a-zA-Z0-9]+)/)
  if !url.nil?
    `open -a /Applications/Spotify.app #{url}`
  end
end
