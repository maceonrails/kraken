module Exports
  class OrderExporter
    include HTTParty

    def initialize
      @base_uri = 'xsquare-api.eresto.co.id/v1'
    end

    def do_export(start_date = nil, last_date = nil)
      last_sync   = Synchronize.order('last_date').last
      start_date  ||= last_sync.nil? ? (Date.parse('16-12-2015').beginning_of_day) : last_sync.last_date
      last_date   ||= start_date+4.hours

      response = HTTParty.post(
        "http://xsquare-api.eresto.co.id/v1/syncs/import_from_cloud", 
        { body: Synchronize.export_from_local(start_date, last_date).to_json }
      )

      if response.code < 300
        Synchronize.create!(last_date: last_date)
      else
        ErrorMailer.error_email(response.code, response.message.to_s, response.body.to_s).deliver_now
      end
    end
  end
end
