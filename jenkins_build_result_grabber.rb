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
build_result = build_hash['result']

puts build_result