class V1::OutletsController < V1::BaseController
  private
    def outlet_params
      params.require(:outlet).permit(:name, :email, :phone, :mobile, :address)
    end

    def query_params
      params.permit(:name)
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end
end
