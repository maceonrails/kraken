# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, Rails.root+"/log/cron_log.log"
#
# every :day, :at => '12:05am' do
#   # command "/usr/bin/some_great_command"
#   runner "Exports::OrderExporter.new.do_export"
# end

every 2.hours do
  runner "Exports::OrderExporter.new.do_export"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# 5 0 * * *