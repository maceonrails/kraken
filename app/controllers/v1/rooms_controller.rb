class V1::RoomsController < V1::BaseController
  skip_before_action :set_resource, only: [:update]

  def index
    @rooms = Room.all
  end

  def create
    Room.create_data params
    to_return = {
      room: {
        'name' => params[:room][:name],
      }
    }

    render json: to_return, status: 201
  end

  def update
    Room.update_data params
    to_return = {
      room: {
        'name' => params[:room][:name],
      }
    }

    render json: to_return, status: 201
  end

  private
    def room_params
      params.require(:room).permit(:name)
    end

    def query_params
      params.permit(:name)
    end

end

