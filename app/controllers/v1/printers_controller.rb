class V1::PrintersController < V1::BaseController
  skip_before_action :authenticate, only: %w(all)
  skip_before_action :set_token_response, only: %w(all)

  private
    def printer_params
      params.require(:printer).permit(:name, :printer, :default)
    end

    def query_params
      params.permit(:name)
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end
end
