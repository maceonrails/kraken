class V1::ProductsController < V1::BaseController
  skip_before_action :authenticate, only: %w(all)
  skip_before_action :set_token_response, only: %w(all)

  def get_by_sub_category
    @products = Product.where(query_params)
    render json: @products, only: [:id, :name, :price, :picture, :sold_out]
  end

  def category
    @categories = Product.uniq.pluck(:category)
    respond_with @categories
  end

  def create
    resource_params[:active] = true
    encode64
    super
  end

  def update
    encode64
    super
  end

  private
    def product_params
      if current_user.role == 'manager'
        params.require(:product).permit(:name, :category, :picture,
          :description, :picture_base64, :product_sub_category_id, :picture_extension, :active,
          :price, :sold_out, :serv_category, :serv_sub_category)
      else
          params.require(:product).permit(:name, :category, :default_price, :sold_out, :serv_category, :serv_sub_category)
      end
    end

    def encode64
      if resource_params[:picture_base64].presence && resource_params[:picture_extension].presence
        filename = SecureRandom.hex.to_s + '.' +resource_params[:picture_extension].downcase
        path     = File.join(Rails.public_path, 'uploads', filename)
        resource_params[:picture] = File.join( '/', 'uploads', filename)

        unless File.directory?(File.join(Rails.public_path, 'uploads'))
          FileUtils.mkdir_p(File.join(Rails.public_path, 'uploads'))
        end

        File.open(path, 'wb') {
          |f| f.write(Base64.decode64(resource_params[:picture_base64].split('base64,').last))}
      end

      #product categories and params
      product_category     = ProductCategory.find_or_create_by(name: resource_params[:serv_category])
      product_sub_category = ProductSubCategory.find_or_create_by(name: resource_params[:serv_sub_category])
      product_sub_category.update(product_category_id: product_category.id, name: resource_params[:serv_sub_category])

      resource_params[:product_sub_category_id] = product_sub_category.id

      resource_params.delete(:picture)
      resource_params.delete(:serv_category)
      resource_params.delete(:serv_sub_category)
    end

    def query_params
      params.permit(:name, :product_sub_category_id)
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end

    def attach_includes
      [:choices, :product_sub_category, product_sub_category: :product_category]
    end
end
