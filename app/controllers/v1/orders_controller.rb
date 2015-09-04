class V1::OrdersController < V1::BaseController
	before_action :set_resource, only: [:update, :show]

  def index
    @orders = Order.where(query_params)
  end

  def pay
    @order = Order.find(params[:order_id])
    @order.pay(params)

    render json: @order, status: 201
  end

  def show
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

    def pay_params
      params.require(:order_items).permit(:quantity)
      
    end

    def query_params
      params.permit(:name, :waiting, :id)
    end

end
