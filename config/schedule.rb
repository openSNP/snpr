# frozen_string_literal: true
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every :day, at: '1am' do
  rake 'numbers:dump', environment: 'production'
  rake 'dump:full', environment: 'production'
end

every :day do
  rake 'papers:update'
end

every :week do
  rake 'recommender:update_all'
end

# The let's encrypt updater stops if the cert is younger than 30 days.
# it's valid for 90 days, so let's ask for the middle.
every 60.days do
  command '/home/app/snpr/bin/ssl_cert.sh'
end
