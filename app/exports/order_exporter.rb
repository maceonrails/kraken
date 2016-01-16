module Exports
  class OrderExporter
    include HTTParty

    def initialize
      @base_uri = 'xsquare-api.eresto.co.id/v1'
    end

    def do_export
      last_sync   = Synchronize.order('created_at').last
      start_date  = last_sync.nil? ? (Date.parse('16-12-2015').beginning_of_day) : last_sync.last_date
      last_date   = start_date.end_of_day+1.days

      response = HTTParty.post(
        "http://#{@base_uri}/syncs/import_from_cloud", 
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
