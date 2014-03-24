#!/usr/bin/env ruby
require 'rubygems'
require 'getopt/long'
require 'mechanize'
require 'json'

opt = Getopt::Long.getopts(
  ["--build_url", "-b", Getopt::REQUIRED]
)

if !opt["b"]
  puts "usage: #{$0} -b <build_url>"
  exit 1
end

agent = Mechanize.new
build_url = opt["build_url"]
build_json = agent.get(URI("#{build_url}api/json")).body
build_hash = JSON.parse(build_json)
build_culprits = build_hash['culprits']

build_culprit_names = ''
if build_culprits.empty?
  puts build_culprits
  exit 0
else
  build_culprits.each do |culprit_hash|
    build_culprit_names += "#{culprit_hash['fullName']}, "
  end
  build_culprit_names = build_culprit_names.strip
  #get rid of the ending comma
  if build_culprit_names =~ /^.+,$/
    build_culprit_names.chop!
  end
  puts build_culprit_names
end