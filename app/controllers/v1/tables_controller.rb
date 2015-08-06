class V1::TablesController < V1::BaseController
  skip_before_action :set_resource, only: [:update]

  def index
    @tables = Table.all
  end

  def search
    query = search_params[:q]
    @tables = Table.where("location LIKE ?", "%#{query}%")

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
      params.require(:table).permit(:name)
    end

    def query_params
      params.permit(:name)
    end

    def attach_includes
      [:parts]
    end
end
