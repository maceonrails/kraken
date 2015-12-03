class V1::DiscountsController < V1::BaseController
  skip_before_action :authenticate, only: %w(all)
  skip_before_action :set_token_response, only: %w(all)

  # GET /api/{plural_resource_name}/all
  def all
    @discounts = Discount.all

    if (@discounts.count > 0)
     respond_with(@discounts) do |format|
       format.json { render :index }
     end
    else
      json_error 'Discount not found', 404
    end
  end

  def search
    field  = search_params[:field].downcase.to_sym
    query  = search_params[:q]
    discounts  = Discount.arel_table
    if search_params[:field] == 'Product'
      @discounts = Discount.joins(:product)
                   .where("products.name ILIKE ?", "%#{query}%")
                   .page(page_params[:page])
                   .per(page_params[:page_size])
      @total     = Discount.joins(:product)
                   .where("products.name ILIKE ?", "%#{query}%")
                   .count
    else
      @discounts = Discount.where(discounts[field]
                   .matches("%#{query}%"))
                   .page(page_params[:page])
                   .per(page_params[:page_size])
      @total     = Discount.where(discounts[field]
                   .matches("%#{query}%"))
                   .count
    end

    respond_with @discounts
  end

  def create
    products = Product.find params[:discount][:products] rescue false
        if products
          resource_params[:products] = products
        else
          resource_params.delete(:products)
        end
    super
  end

  def update
    products = Product.find params[:discount][:products] rescue false
    if products
      resource_params[:products] = products
    else
      resource_params.delete(:products)
    end
    super
  end

  def destroy
    begin
      get_resource.active = !get_resource.active
      get_resource.save
      render :show
    rescue => e
      relations = resource_class.reflect_on_all_associations.map { |e| e.name.to_s }
      error_msg = "Cannot deactive/delete #{resource_name}, still have link with the following: #{relations.join(',')}"
      render json: { message: error_msg }, status: 200
    end
  end

  private
    def discount_params
      params.require(:discount).permit(:name, :amount,
        :product_id, :start_date, :end_date, :end_time, :start_time, :percentage, days: [])
    end

    def query_params
      params.permit(:name)
    end

    def attach_includes
      [:products]
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end
end
