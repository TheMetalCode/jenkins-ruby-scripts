#!/usr/bin/env ruby
require 'rubygems'
require 'getopt/long'
require 'yaml'

opt = Getopt::Long.getopts(
  ["--job_name", "-j", Getopt::REQUIRED],
  ["--build_url", "-b", Getopt::REQUIRED],
  ["--job_status", "-s", Getopt::REQUIRED],
  ["--last_committer", "-c", Getopt::OPTIONAL],
  ["--hipchat_token", "-t", Getopt::REQUIRED],
  ["--build_branch", "-r", Getopt::REQUIRED],
  ["--build_culprits", "-p", Getopt::OPTIONAL]
)

#every single param is required
if !opt["job_name"] || !opt["build_url"] || !opt["job_status"] || !opt["hipchat_token"] || !opt["build_branch"]
  puts "usage: #{$0} \n -j <job name> \n -b <build url> \n -s <job status> \n -c <last comitter, aka the person we're blaming for breaking the build> \n -t <hipchat api token> \n -r <branch that was built> \n -p <build culprits>"
  exit 1
end

job_name = opt["job_name"]
build_url = opt["build_url"]
job_status = opt["job_status"]
hipchat_token = opt["hipchat_token"]
build_branch = opt["build_branch"]
last_committer = opt["last_committer"]
build_culprits = opt["build_culprits"]

#if job_status = ABORTED, not notifying
if job_status == "ABORTED"
  puts "Not notifying HipChat of an aborted build"
  exit 0
end

#determine rooms to notify

rooms_config = nil
job_config = nil
begin
  rooms_config = YAML.load_file('hipchat_rooms.yml')
  job_config = YAML.load_file('jenkins_jobs.yml')["#{job_name}"]
rescue
  puts "Please make sure you have a properly configured hipchat_rooms.yml and jenkins_jobs.yml in your scripts directory, see README"
  exit 1
end

master_rooms = rooms_config['master_branch']['rooms']
non_master_rooms = rooms_config['non_master_branches']['rooms']
rooms = []

if build_branch == 'master' and job_config['notify_master_rooms']
  rooms = master_rooms
else
  rooms = non_master_rooms
end

#lets craft the message here, which hinges on job status and people to blame
room_message = ''
case job_status
when "SUCCESS"
  room_message = "Successful build for #{job_name}: #{build_url}"
when "FAILURE"
  #as far as people to blame, prefer culprits, but fall back to last comitter
  if !build_culprits.nil? and !build_culprits.empty?
    build_culprits = build_culprits.strip
    room_message = "#{build_culprits} broke the build for #{job_name}: #{build_url}"
  elsif !last_committer.nil? and !last_committer.empty?
    last_committer = last_committer.strip
    room_message = "#{last_committer} broke the build for #{job_name}: #{build_url}"
  else
    room_message = "The build is broken for #{job_name} and I have nobody to blame: #{build_url}"
  end
else
  #do nothing
end

rooms.each do |room|
  case job_status
  when "SUCCESS"
    puts "Sending success notification to room #{room}"
    `echo #{room_message} | ./hipchat_room_message -t #{hipchat_token} -r #{room} -f 'Leeroy Jenkins' -c green`
  when "FAILURE"
    puts "Sending failure notification to room #{room}"
    `echo #{room_message} | ./hipchat_room_message -t #{hipchat_token} -r #{room} -f 'Leeroy Jenkins' -c red -n`
  else
    #nothing
  end
end
