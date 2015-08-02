class V1::OutletsController < V1::BaseController
  private
    def outlet_params
      params.require(:outlet).permit(:name, :email, :phone, :mobile, :address)
    end

    def query_params
      params.permit(:name)
    end
end
