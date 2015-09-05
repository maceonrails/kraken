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

  def get
    @order = Order.includes(:order_items, :table, order_items: :product).find(params[:id])
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

    def pay_params
      params.require(:order_items).permit(:quantity)

    end

    def query_params
      params.permit(:name, :waiting, :id)
    end

    def from_servant_params
      params.require(:order).permit(:id, :servant_id, :table_id, :name,
        products: [:id, :quantity, :take_away, :void, :void_note, :choice, :price, :void_by, note:[]])
    end

end
