class V1::OrdersController < V1::BaseController
	before_action :set_resource, only: [:update, :show]

  def index
    @orders = Order.where(query_params)
  end

  def waiting_orders
    @orders = Order.get_waiting_orders
    render json: @orders, status: 201
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
    else
      date_start = date.beginning_of_week
      date_end   = date.end_of_week
    end
    data = Order
            .joins(:order_items)
            .where('orders.created_at >= ? and orders.created_at <= ? AND order_items.void IS NOT TRUE', date_start, date_end)
            .select("DATE(orders.created_at) as created_at, sum(order_items.paid_amount) as name")
            .group('orders.created_at')
            .map{|o| [o.created_at.to_f * 1000, o.name.to_i]}
    render json: data, status: 200
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
    else
      date_start = date.beginning_of_week
      date_end   = date.end_of_week
    end
    data = Order
            .joins(:order_items)
            .where('orders.created_at >= ? and orders.created_at <= ? AND order_items.void IS NOT TRUE', date_start, date_end)
            .select("DATE(orders.created_at) as created_at, count(order_items.id) as name")
            .group('orders.created_at')
            .map{|o| [o.created_at.to_f * 1000, o.name.to_i]}
    render json: data, status: 200
  end

  def pay_order
    if Order.pay_order(pay_params)
      render json: { message: 'Ok' }, status: 201
    else
      render json: { message: "pay order failed" }, status: 409
    end
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
    query  = params[:data] || ''
    orders = Order.joins(:table)
                  .where(created_at: (Date.parse(params[:dateStart])).beginning_of_day..(Date.parse(params[:dateEnd])).end_of_day)
                  .where("tables.name LIKE ? OR orders.name LIKE ?", "%#{query}%", "%#{query}%")
    @orders = orders.page(page_params[:page]).per(10)
    @total  = orders.count
  end

  def print
    order = Order.where(id: params[:id])

    if order.blank?
      render json: { message: 'Order not found' }, status: 404

    else
      printed = Order.new.do_print(params)
      if printed[:status]
        if printed[:printed]
          render json: { message: 'Ok' }, status: 200
        else
          render json: { message: 'No data to print' }, status: 400
        end
      else
        render json: { message: 'Failed to print, please try again.' }, status: 500
      end
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

  private
    def order_params
      params.require(:order).permit(:name)
    end

    def query_params
      params.permit(:name, :waiting, :id)
    end

    def pay_params
      params.permit(:id, :servant_id, :table_id, :name, :discount_by, :discount_amount, :cash_amount,
        order_items: [:id, :quantity, :take_away, :void, :void_note, :saved_choice, :paid_quantity, 
          :pay_quantity, :paid, :void_by, :note, :product_id, :price]
      )
    end

    def from_servant_params
      params.require(:order).permit(:id, :servant_id, :table_id, :name,
        products: [:id, :quantity, :take_away, :void, :void_note, :choice, :price, :void_by, :order_item_id, note:[]])
    end

end
