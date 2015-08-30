class V1::OrderItemsController < V1::BaseController
	skip_before_action :set_resource, only: [:update]

  def index
    @order_items = OrderLine.where(query_params)
  end

  def create
    order_line = OrderLine.new order_item_params

    if order_line.save
    	render json: order_line, status: 201
    else
    	render json: { message: "create order failed" }, status: 409
    end
  end

  def update
    if @order_item.update order_item_params
    	render json: to_return, status: 201
    else
    	render json: to_return, status: 409
    end
  end

  private
    def order_item_params
     	params.permit(:order_id, :product_id, :quantity, :choice_id, :note, :payment_id, :served, :void)
    end

    def query_params
      params.permit(:order_id, :payment_id, :served)
    end

end
