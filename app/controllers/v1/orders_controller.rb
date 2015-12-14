class V1::OrdersController < V1::BaseController
	before_action :set_resource, only: [:update, :show]

  def index
    @orders = Order.where(query_params)
  end

  def waiting_orders
    @orders = Order.waiting_orders
    render json: @orders, status: 201
  end

  def history_orders
    @orders = Order.histories.search(params[:q]).page(page_params[:page]).per(page_params[:page_size])
    render json: @orders, include: [:table, :payment], status: 201
  end

  def discount_order
    if user = User.can_discount?(params[:email], params[:password])
      render json: { user: user }, status: 201
    else
      render json: { message: "not verified" }, status: 409
    end
  end

  def toggle_served
    order = Order.find(params[:id])
    order.toggle :created
    if order.save
      render json: order, status: 201
    else
      render json: order, status: 409
    end
  end
  
  def toggle_pantry
    order = Order.find(params[:id])
    order.toggle :pantry_created 
    if order.save
      render json: order, status: 201
    else
      render json: order, status: 409
    end
  end

  def graph_by_revenue
    date  = Date.today
    case params[:timeframe]
    when 'last_three_months'
      date_start = (date - 3.months).beginning_of_month
      date_end   = date.end_of_month
    when 'last_six_months'
      date_start = (date - 6.months).beginning_of_month
      date_end   = date.end_of_month
    when 'this_year'
      date_start = date.beginning_of_year
      date_end   = date.end_of_month
    when 'last_three_year'
      date_start = (date - 3.years).beginning_of_year
      date_end   = date.end_of_month
    when 'this_month'
      date_start = date.beginning_of_month
      date_end   = date.end_of_month
    when 'this_week'
      date_start = date.beginning_of_week
      date_end   = date.end_of_week
    else
      date_start = date.beginning_of_day
      date_end   = date.end_of_day
    end
    data = OrderItem
            .where('order_items.created_at >= ? and order_items.created_at <= ?', date_start, date_end)
            .select("DATE(order_items.created_at) as created_at, sum(order_items.paid_amount) as name")
            .group('order_items.created_at')
            .order('order_items.created_at')
    data = data.joins(order: :table).where('tables.outlet_id = ?', params[:outlet_id]) if params[:outlet_id].present?
    data = data.joins(:product).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
    data = data.group("products.tenant_id, order_items.id") if params[:tenant_id].present?
    render json: data.map{|o| [o.created_at.to_f * 1000, o.name.to_i]}, status: 200
  end

  def graph_by_tax
    date  = Date.today
    case params[:timeframe]
    when 'last_three_months'
      date_start = (date - 3.months).beginning_of_month
      date_end   = date.end_of_month
    when 'last_six_months'
      date_start = (date - 6.months).beginning_of_month
      date_end   = date.end_of_month
    when 'this_year'
      date_start = date.beginning_of_year
      date_end   = date.end_of_month
    when 'last_three_year'
      date_start = (date - 3.years).beginning_of_year
      date_end   = date.end_of_month
    when 'this_month'
      date_start = date.beginning_of_month
      date_end   = date.end_of_month
    when 'this_week'
      date_start = date.beginning_of_week
      date_end   = date.end_of_week
    else
      date_start = date.beginning_of_day
      date_end   = date.end_of_day
    end
    data = OrderItem
            .where('order_items.created_at >= ? and order_items.created_at <= ?', date_start, date_end)
            .select("DATE(order_items.created_at) as created_at, sum(order_items.tax_amount) as name")
            .group('order_items.created_at')
            .order('order_items.created_at')
    data = data.joins(order: :table).where('tables.outlet_id = ?', params[:outlet_id]) if params[:outlet_id].present?
    data = data.joins(:product).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
    data = data.group("products.tenant_id, order_items.id") if params[:tenant_id].present?
    render json: data.map{|o| [o.created_at.to_f * 1000, o.name.to_i]}, status: 200
  end

  def graph_by_order
    date  = Date.today
    case params[:timeframe]
    when 'last_three_months'
      date_start = (date - 3.months).beginning_of_month
      date_end   = date.end_of_month
    when 'last_six_months'
      date_start = (date - 6.months).beginning_of_month
      date_end   = date.end_of_month
    when 'this_year'
      date_start = date.beginning_of_year
      date_end   = date.end_of_month
    when 'last_three_year'
      date_start = (date - 3.years).beginning_of_year
      date_end   = date.end_of_month
    when 'this_month'
      date_start = date.beginning_of_month
      date_end   = date.end_of_month
    when 'this_week'
      date_start = date.beginning_of_week
      date_end   = date.end_of_week
    else
      date_start = date.beginning_of_day
      date_end   = date.end_of_day
    end
    data = OrderItem
            .where('order_items.created_at >= ? and order_items.created_at <= ? AND order_items.void IS NOT TRUE', date_start, date_end)
            .select("DATE(order_items.created_at) as created_at, count(order_items.paid_quantity) as name")
            .group('order_items.created_at')
            .order('order_items.created_at')

    data = data.joins(order: :table).where('tables.outlet_id = ?', params[:outlet_id]) if params[:outlet_id].present?
    data = data.joins(:product).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
    data = data.group("products.tenant_id, order_items.id") if params[:tenant_id].present?
    render json: data.map{|o| [o.created_at.to_f * 1000, o.name.to_i]}, status: 200
  end

  def graph_by_pax
    date  = Date.today
    case params[:timeframe]
    when 'last_three_months'
      date_start = (date - 3.months).beginning_of_month
      date_end   = date.end_of_month
    when 'last_six_months'
      date_start = (date - 6.months).beginning_of_month
      date_end   = date.end_of_month
    when 'this_year'
      date_start = date.beginning_of_year
      date_end   = date.end_of_month
    when 'last_three_year'
      date_start = (date - 3.years).beginning_of_year
      date_end   = date.end_of_month
    when 'this_month'
      date_start = date.beginning_of_month
      date_end   = date.end_of_month
    when 'this_week'
      date_start = date.beginning_of_week
      date_end   = date.end_of_week
    else
      date_start = date.beginning_of_day
      date_end   = date.end_of_day
    end
    data = OrderItem
            .where('order_items.created_at >= ? and order_items.created_at <= ? AND order_items.void IS NOT TRUE', date_start, date_end)
            .select("DATE(order_items.created_at) as created_at, count(order_items) as name")
            .group('order_items.created_at')
            .order('order_items.created_at')

    data = data.joins(order: :table).where('tables.outlet_id = ?', params[:outlet_id]) if params[:outlet_id].present?
    data = data.joins(:product).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
    data = data.group("products.tenant_id, order_items.id") if params[:tenant_id].present?
            
    render json: data.map{|o| [o.created_at.to_f * 1000, o.name.to_i]}, status: 200
  end

  def get_order_quantity
    order = 'ASC'
    data  = Product.joins('LEFT OUTER JOIN "order_items" ON "order_items"."product_id" = "products"."id"')
                   .select("(products.name) as name, sum(order_items.quantity) as price")
                   .group('products.name')
                   .order("price")
    data = data.where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
    data = data.map{|o| [o.name, o.price.to_i]}
    render json: data, status: 200
  end

  def make_order
    if Order.make_order(pay_params)
      render json: { message: 'Ok' }, status: 201
    else
      render json: { message: "create order failed" }, status: 409
    end
  end

  def show
  end

  def get
    @order = Order.includes(:order_items, :table, order_items: :product).find(params[:id])
  end

  def search
    if params[:type]
      puts '==========='
      puts 'today'
      orders = Order
                .includes(:table, :order_items, order_items: :product)
                .where(created_at: Date.today.beginning_of_day..Date.today.end_of_day)
                .all
      orders = orders.joins(:table).where("tables.outlet_id = ?", params[:outlet_id]) if params[:outlet_id].present?
      orders = orders.joins(order_items: :product).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
      @orders = orders
      @total  = @orders.count || 0
    elsif params[:dateStart] && params[:dateEnd]
      query  = params[:data] || ''
      orders = Order.joins('LEFT OUTER JOIN "tables" on "tables"."id" = "orders"."table_id"')
                    .where(created_at: (Date.parse(params[:dateStart])).beginning_of_day..(Date.parse(params[:dateEnd])).end_of_day)
                    .where("tables.name LIKE ? OR orders.name LIKE ?", "%#{query}%", "%#{query}%")
      orders = orders.joins(:table).where("tables.outlet_id = ?", params[:outlet_id]) if params[:outlet_id].present?
      orders = orders.joins(order_items: :product).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
      orders = orders.group("products.tenant_id, orders.id") if params[:tenant_id].present?
      @orders = orders.page(page_params[:page]).per(10)
      @total  = orders.count || 0
    else
      render json: {message: 'order not found'}, status: 404
    end
  end

  def from_servant
    if Order.save_from_servant(from_servant_params)
      render json: { message: 'Ok' }, status: 201
    else
      render json: { message: "create order failed" }, status: 409
    end
  end

  def create
    order = Order.new order_params

    if order.save
    	render json: order, status: 201
    else
    	render json: { message: "create order failed" }, status: 409
    end
  end

  def update
    if @order.update order_params
    	render json: @order, status: 201
    else
    	render json: @order, status: 409
    end
  end

  def destroy
    @order = Order.find(params['id'])
    if @order.destroy
      render json: { message: 'success deleted' }, status: 201
    else
      render json: { message: 'delete failed' }, status: 404
    end
  end

  def set_resource(resource = nil)
    tables = Table.where(name: params[:id].split(","))
    @orders = Order.find(tables.map(&:order_id))
  end

  private
    def order_params
      params.require(:order).permit(:name, :person, :cashier_id)
    end

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

    def oc_params
      params.permit(:id, :order_id, :servant_id, :table_id, :name, :cashier_id, :email, :password, :note,
        order_items: [:id, :quantity, :pay_quantity, :take_away, :print_quantity, :product_id]
      )
    end

    def pay_params
      params.permit(:id, :servant_id, :table_id, :name, :discount_by, :discount_amount, :discount_percent, :void, :cashier_id,
        :credit_amount, :debit_amount, :cash_amount, :debit_name, :credit_name, :credit_number, :debit_number, :type,
        order_items: [:id, :quantity, :take_away, :void, :void_note, :saved_choice, :paid_quantity, :print_quantity,
          :pay_quantity, :paid, :void_by, :note,  :product_id,
          :price,:discount_id]
      )
    end

    def from_servant_params
      params.require(:order).permit(:id, :servant_id, :table_id, :name, :person,
        products: [:id, :quantity, :take_away, :void, :void_note, :choice, :price, :void_by, :order_item_id, note:[]])
    end

end
