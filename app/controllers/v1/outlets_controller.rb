class V1::OutletsController < V1::BaseController
  skip_before_action :authenticate, only: %w(all)
  skip_before_action :set_token_response, only: %w(all)

  private
    def outlet_params
      params.require(:outlet).permit(:name, :email, :phone, :mobile, :address, :taxs).tap do |whitelisted|
        whitelisted[:taxs] = params[:outlet][:taxs]
      end
    end

    def query_params
      params.permit(:name)
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end
end
