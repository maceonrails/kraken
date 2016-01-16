module Exports
  class OrderExporter
    include HTTParty

    def initialize
      @base_uri = 'xsquare-api.eresto.co.id/v1'
    end

    def do_export
      response = HTTParty.post("http://#{@base_uri}/syncs/import_from_cloud", { body: Synchronize.export_from_local().to_json })
      if response.code < 300
        Synchronize.create!(last_date: last_date)
      else
        ErrorMailer.error_email(response.code, response.message.to_s, response.body.to_s).deliver_now
      end
    end
  end
end
