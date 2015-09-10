require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

# synx order data to cloud every day, five minutes after midnight
scheduler.cron '5 0 * * *' do
  Exports::OrderExporter.new.do_export
  Table.update_all(order_id: nil)
end