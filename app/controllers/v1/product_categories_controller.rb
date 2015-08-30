class V1::ProductCategoriesController < V1::BaseController
	skip_before_action :set_resource, only: [:update]

  def index
    @product_categories = ProductCategory.where(query_params)
  end

  def create
    product_category = ProductCategory.new product_category_params

    if product_category.save
    	render json: product_category, status: 201
    else
    	render json: { message: "create product_category failed" }, status: 409
    end
  end

  def update
    if @product_category.update product_category_params
    	render json: @product_category, status: 201
    else
    	render json: @product_category, status: 409
    end
  end

  private
    def product_category_params
      params.permit(:name)
    end

    def query_params
      params.permit(:name)
    end

end
