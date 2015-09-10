module Exports
  class OrderExporter
    include HTTParty

    def initialize
      @base_uri = 'api-bober.io/v1'
    end

    def do_export
      last_sync   = Synchronize.order('created_at').last
      outlet      = Outlet.first
      orders      = Order.where(created_at: last_sync.created_at.beginning_of_day..Time.zone.now.end_of_day)
      order_items = OrderItem.where(created_at: last_sync.created_at.beginning_of_day..Time.zone.now.end_of_day)
      data        = { orders: orders, order_items: order_items, outlet: outlet }

      response    = HTTParty.post("http://#{@base_uri}/orders/import", { body: data.to_json })
      if response.code < 300
        Synchronize.create!
      else
        ErrorMailer.error_email(response.code, response.message.to_s, response.body.to_s).deliver_now
      end
    end
  end
end
