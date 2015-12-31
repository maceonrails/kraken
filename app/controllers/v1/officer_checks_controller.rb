class V1::OfficerChecksController < V1::BaseController

  def search
    if params[:type]
      puts '==========='
      puts 'today'
      order_items = OrderItem
                .includes(:order)
                .where(created_at: Date.today.beginning_of_day..Date.today.end_of_day)
                .all
      order_items = order_items.joins(order: :table).where("tables.outlet_id = ?", params[:outlet_id]) if params[:outlet_id].present?
      order_items = order_items.joins(:product).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
      @order_items = order_items
      @total  = @order_items.count || 0
    elsif params[:dateStart] && params[:dateEnd]
      query  = params[:data] || ''
      order_items = OrderItem.joins(:product, order: :table)
                    .joins("LEFT JOIN users ON users.id = order_items.oc_by LEFT JOIN profiles ON profiles.user_id = users.id")
                    .where('oc_quantity > 0')
                    .where(created_at: (Date.parse(params[:dateStart])).beginning_of_day..(Date.parse(params[:dateEnd])).end_of_day)
                    .where("products.name LIKE ? OR tables.name LIKE ? OR profiles.name LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
      order_items = order_items.where("tables.outlet_id = ?", params[:outlet_id]) if params[:outlet_id].present?
      order_items = order_items.where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
      order_items = order_items.order("order_items.updated_at DESC")
      order_items = order_items.uniq

      if page_params[:page_size] == 'all'
        @order_items = order_items.page(page_params[:page]).per(OrderItem.count)
      else
        @order_items = order_items.page(page_params[:page]).per(page_params[:page_size])
      end
      @total  = order_items.count || 0
    else
      render json: {message: 'OrderItem not found'}, status: 404
    end
  end

  private
    def query_params
      params.permit(:name, :waiting, :id)
    end

    def void_item_params
      params.require(:order_item).permit(:id, :quantity, :take_away, :void, :void_note, :saved_choice, :paid_quantity,
          :pay_quantity, :paid, :void_by, :note, :product_id, :price)
    end

    def void_params
      params.permit(:id, :order_id, :servant_id, :table_id, :name, :cashier_id, :email, :password, :note,
        order_items: [:id, :quantity, :pay_quantity, :take_away, :print_quantity, :product_id]
      )
    end
end
