TheCity Jenkins Scripts
=======================

Ruby versions tested:

* ree-1.8.7-2011.03
* ruby-1.9.3-p484
* ruby-2.0.0-p353
* ruby-2.1.0
* jruby-1.7.10

These are some ruby scripts I wrote to assist in our Jenkins implementation at [The City](http://github.com/thecity), specifically relating to post-build tasks. Each of these scripts can be executed in a [shell post-build task](https://wiki.jenkins-ci.org/display/JENKINS/PostBuildScript+Plugin).

### jenkins_build_result_grabber.rb ###

This script accepts a build url (http://your_jenkins_server/job/some_job/some_build_number), uses the Jenkins REST API to grab the build result, and returns it to STDOUT.

### jenkins_build_culprits_grabber.rb ###

This script accepts a build url (http://your_jenkins_server/job/some_job/some_build_number), uses the Jenkins REST API to grab the build culprits, and returns a comma-separated string of names to STDOUT.

### jenkins_hipchat_notifier.rb ###

I wrote this script because I wanted hipchat notifications to fire after each build, but wanted more control over the details than the [Hipchat plugin](https://wiki.jenkins-ci.org/display/JENKINS/HipChat+Plugin) allows for.

This script uses the hipchat_room_message shell script from [hipchat-cli](https://github.com/hipchat/hipchat-cli) and assumes that you have that script in the same directory in which you'll be executing this ruby script. Naturally, you'll also need to pass in a Hipchat API token.

This script also reads from two YAML config files that you must provide:

* hipchat_rooms.yml - This is where you define your room ids, specifying which rooms should be notified on builds of master branches and builds of non-master branches.

```ruby
master_branch:
  rooms: [room1, room2, room3]

non_master_branches:
  rooms: [room1]
```

* jenkins_jobs.yml - This is where you define your build jobs (they should be named exactly as you've named them in Jenkins) and whether or not you want to notify an extended list of rooms for its master branch builds.

```ruby
somejob:
  notify_master_rooms: true

anotherjob:
  notify_master_rooms: false
```

Given the right configurations and params are provided, this script will send the right notification to the right rooms, and blame the right people in the case of a build failure.


