class V1::DiscountsController < V1::BaseController
  skip_before_action :authenticate, only: %w(all)
  skip_before_action :set_token_response, only: %w(all)

  # GET /api/{plural_resource_name}/all
  def all
    @discounts = Discount.where("'#{params[:outlet_id]}' = ANY (outlets)")

    if (@discounts.count > 0)
     respond_with(@discounts) do |format|
       format.json { render :index }
     end
    else
      json_error 'Discount not found', 404
    end
  end

  private
    def all_params

    end

    def discount_params
      params.require(:discount).permit(:name, :amount, :product_id, outlets: [])
    end

    def query_params
      params.permit(:name)
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end
end
