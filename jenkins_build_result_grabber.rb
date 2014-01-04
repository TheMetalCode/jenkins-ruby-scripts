#!/usr/bin/env ruby
require 'rubygems'
require 'getopt/long'
require 'net/http'
require 'json'

opt = Getopt::Long.getopts(
  ["--build_url", "-b", Getopt::REQUIRED]
)

if !opt["b"]
  puts "usage: #{$0} -b <build_url>"
  exit 1
end

build_url = opt["build_url"]
build_json = Net::HTTP.get(URI("#{build_url}api/json"))
build_hash = JSON.parse(build_json)
build_result = build_hash['result']

puts build_result