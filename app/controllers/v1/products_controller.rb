class V1::ProductsController < V1::BaseController
  skip_before_action :authenticate, only: %w(all)
  skip_before_action :set_token_response, only: %w(all)

  def get_by_sub_category
    @products = Product.where(query_params)
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
      params.require(:product).permit(:name, :category, :default_price, :picture,
        :description, :picture_base64, :picture_extension, :active, :price)
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
      resource_params.delete(:picture)
    end

    def query_params
      params.permit(:name, :product_sub_category_id)
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end
end
