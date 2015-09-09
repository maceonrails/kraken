module Exports
  class OrderExporter
    include HTTParty

    def initialize
      @base_uri = 'localhost:4000/v1'
    end

    def do_export
      outlet      = Outlet.first
      orders      = Order.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
      order_items = OrderItem.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
      data        = { orders: orders, order_items: order_items, outlet: outlet }

      respose     = HTTParty.post("http://#{@base_uri}/orders/import", { body: data.to_json })
    end
  end
end
  