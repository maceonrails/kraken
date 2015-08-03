class V1::ProductsController < V1::BaseController
  def category
    @categories = Product.uniq.pluck(:category)
    respond_with @categories
  end

  def create
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
        :description, :picture_base64, :picture_extension)
    end

    def encode64
      if resource_params[:picture_base64].presence
        filename = SecureRandom.hex.to_s + '.' +resource_params[:picture_extension]
        path     = File.join(Rails.public_path, 'uploads', filename)
        resource_params[:picture] = File.join( request.protocol + request.host_with_port,  'uploads', filename)

        unless File.directory?(File.join(Rails.public_path, 'uploads'))
          FileUtils.mkdir_p(File.join(Rails.public_path, 'uploads'))
        end

        File.open(path, 'wb') {
          |f| f.write(Base64.decode64(resource_params[:picture_base64].split('base64,').last))}
      end
    end

    def query_params
      params.permit(:name)
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end
end
