class V1::TablesController < V1::BaseController
  skip_before_action :set_resource, only: [:update]
  skip_before_action :authenticate, only: %w(all)
  skip_before_action :set_token_response, only: %w(all)

  def index
    @tables   = Table.includes(:parts).all
  end

  def locations
    @locations = Table.select(:location).uniq
  end

  def moving
    from = Table.find(params[:from])
    to   = Table.find(params[:to])
    to.update(order_id: from.order_id)
    from.update(order_id: nil)

    render json: { message: 'Ok' }, status: 200
  end

  def linking
    from = Table.find(params[:from])
    to   = Table.find(params[:to])
    to.update(order_id: from.order_id)

    render json: { message: 'Ok' }, status: 200
  end

  def search
    query = search_params[:q]
    @tables = Table.includes(:parts).where("location LIKE ?", "%#{query}%")
    @total  = @tables.count

    respond_with(@tables) do |format|
      format.json { render :index }
    end
  end

  def create
    Table.create_data params
    to_return = {
      table: {
        'location' => params[:table][:location],
        'start'    => params[:table][:start],
        'end'      => params[:table][:end]
      }
    }

    render json: to_return, status: 201
  end

  def change
    @table = Table.find(params[:id])
    if @table.update table_params
      render json: @table, status: 201
    else
      render json: @table, status: 409
    end
  end

  def update
    Table.update_data params
    to_return = {
      table: {
        'location' => params[:table][:location],
        'start'    => params[:table][:start],
        'end'      => params[:table][:end]
      }
    }

    render json: to_return, status: 201
  end

  private
    def table_params
      params.require(:table).permit(:name, :occupied, :status, :order_id)
    end

    def query_params
      params.permit(:name)
    end

    def attach_includes
      [:parts]
    end
end
