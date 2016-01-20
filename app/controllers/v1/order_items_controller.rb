class V1::OrderItemsController < V1::BaseController
	skip_before_action :set_resource, only: [:update]

  def index
    @order_items = OrderItem.where(query_params)
  end

  def active_items
    order = Order.find(params[:order_id])
    if order_items = order.get_active_items
      render json: order_items, include: { product: { only: [:id, :price] } }, status: 201
    else
      render json: {message: "something when wrong"}, status: 409
    end
  end

  def void_items
    if user = User.can_void?(params[:email], params[:password])
      if orders = OrderItem.void_items(user, void_params)
        render json: { message: 'Ok' }, status: 201
      else
        render json: { message: "Void items failed" }, status: 409
      end
    else
      render json: { message: "not verified" }, status: 409
    end
  end

  def oc_items
    if user = User.can_oc?(params[:email], params[:password])
      if orders = OrderItem.oc_items(user, void_params, current_user)
        render json: { message: 'Ok' }, status: 201
      else
        render json: { message: "OC items failed" }, status: 409
      end
    else
      render json: { message: "not verified" }, status: 409
    end
  end

  def void_item
    if Order.void_item(void_item_params)
      render json: { message: 'Ok' }, status: 201
    else
      render json: { message: "create order failed" }, status: 409
    end
  end

  def toggle_served
    order_item = OrderItem.find(params[:id])
    order_item.toggle :served 
    if order_item.save
      render json: order_item, status: 201
    else
      render json: order_item, status: 409
    end
  end

  def create
    order_item = OrderItem.new order_item_params

    if order_item.save
    	render json: order_item, status: 201
    else
    	render json: { message: "create order failed" }, status: 409
    end
  end

  def update
    @order_item = OrderItem.find(params[:id])
    if @order_item.update order_item_params
    	render json: @order_item, status: 201
    else
    	render json: @order_item, status: 409
    end
  end

  def search
    query  = params[:data] || ''
    result = OrderItem.joins('
      RIGHT OUTER JOIN "products" on "products"."id" = "order_items"."product_id" 
      INNER JOIN "users" on "users"."id" = "products"."tenant_id"
    ')
    result = OrderItem.joins(product: :tenant)
      .select("
        products.tenant_id as tenant_id,
        products.name as name, 
        sum(order_items.quantity) as quantity, 
        sum(order_items.paid_quantity) as paid_quantity, 
        sum(order_items.void_quantity) as void_quantity, 
        sum(order_items.oc_quantity) as oc_quantity, 
        sum(order_items.tax_amount) as tax_amount,
        sum(order_items.paid_amount) as paid_amount
      ")
      .where("LOWER(products.name) LIKE ?", "%#{query.downcase}%")
      .order("paid_amount desc")

    if params[:dateStart].present? && params[:dateEnd].present?
      start_date = Date.parse(params[:dateStart]).beginning_of_day
      end_date = Date.parse(params[:dateEnd]).end_of_day
      result = result.where('order_items.created_at >= ? and order_items.created_at <= ?', start_date, end_date)
    end

    result = result.joins(order: :table).where("tables.outlet_id = ?", params[:outlet_id]) if params[:outlet_id].present?
    result = result.where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
    result = result.group("products.tenant_id, products.name")

    render json: { result: result }
  end

  private
    def order_item_params
     	params.require(:order_item).permit(:order_id, :product_id, :quantity, :choice_id, :paid_amount, :note, :served, :void, :paid)
    end

    def void_params
      params.permit!
    end

    def query_params
      params.permit(:order_id, :served, :void, :paid)
    end

end
