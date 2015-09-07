class Order < ActiveRecord::Base
	has_many   :order_items
  belongs_to :discount_provider, foreign_key: :discount_by, class_name: 'User'
  belongs_to :table

  def self.save_from_servant(params)
    begin
      if params['id']
        order = Order.find(params['id'])
      else
        order = Order.create
      end

      #save or update order
      order.update name: params['name'], table_id: params['table_id'], servant_id: params['servant_id']

      # update table data with order id
      Table.update(params['table_id'], order_id: order.id)

      #get taxs
      taxs  = Outlet.first.taxs;

      # order_item
      params['products'].each do |prd|
        discount = Discount.where(product_id: prd['id']).last
        discount = discount.nil? ? 0 : discount.amount.to_i
        tax_component = 0;
        taxs.each_pair do |name, amount|
          percentage = amount.to_f / 100
          tax_component += (percentage * prd['price'].to_i).to_i
        end rescue true

        if prd['order_item_id']
          orderItem = OrderItem.find(prd['order_item_id'])
        else
          orderItem = OrderItem.create
        end

        orderItem.update(
          order_id:         order.id,
          product_id:       prd['id'],
          quantity:         prd['quantity'],
          note:             prd['note'].nil? ? '' : prd['note'].join(','),
          void:             prd['void'],
          paid_amount:      (tax_component - discount + prd['price'].to_i),
          tax_amount:       tax_component,
          discount_amount:  discount,
          void_note:        prd['void_note'],
          take_away:        prd['take_away'],
          saved_choice:     prd['choice'],
          void_by:          prd['void_by']
        )
      end

      return true
    rescue Exception => e
      return false
    end
  end
end
