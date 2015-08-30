class V1::ProductSubCategoriesController < V1::BaseController
		skip_before_action :set_resource, only: [:update]

  def index
  	product_category = ProductCategory.find(params[:product_category_id])
    @product_sub_categories = product_category.product_sub_categories.where(query_params)
  end

  def create
    product_sub_category = ProductSubCategory.new product_sub_category_params

    if product_sub_category.save
    	render json: product_sub_category, status: 201
    else
    	render json: { message: "create sub category failed" }, status: 409
    end
  end

  def update
    if @product_sub_category.update product_sub_category_params
    	render json: @product_sub_category, status: 201
    else
    	render json: @product_sub_category, status: 409
    end
  end

  private
    def product_sub_category_params
      params.permit(:name)
    end

    def query_params
      params.permit(:name)
    end


end
