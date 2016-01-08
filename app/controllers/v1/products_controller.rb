class V1::ProductsController < V1::BaseController
  skip_before_action :authenticate, only: %w(all)
  skip_before_action :set_token_response, only: %w(all)

  def get_by_tenant
    @products = Product.where(tenant: current_user)
    respond_with(@products) do |format|
      format.json { render :index }
    end
  end

  def get_by_sub_category
    @products = Product.where(query_params)
    render json: @products, only: [:id, :name, :price, :picture, :sold_out]
  end

  def category
    @categories = ProductCategory.all
    respond_with @categories
  end

  def create
    resource_params[:active] = true
    encode64
    super
  end

  def get_top_foods
    order = 'ASC'
    data  = Product.joins('LEFT OUTER JOIN "order_items" ON "order_items"."product_id" = "products"."id"')
                   .joins(tenant: :profile)
                   .select("(products.name) as name, sum(order_items.quantity) as quantity, profiles.name as tenant_name")
                   .where("products.category = 'food'")
                   .group('products.name, profiles.name')
                   .order("quantity")
                   .limit(10)
    data = data.where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
    data = data.map{|o| [o.name, o.quantity.to_i, o.tenant_name]}
    render json: data, status: 200
  end

  def get_top_drinks
    order = 'ASC'
    data  = Product.joins('LEFT OUTER JOIN "order_items" ON "order_items"."product_id" = "products"."id"')
                   .joins(tenant: :profile)
                   .select("(products.name) as name, sum(order_items.quantity) as quantity, profiles.name as tenant_name")
                   .where("products.category = 'drink'")
                   .group('products.name, profiles.name')
                   .order("quantity")
                   .limit(10)
    data = data.where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
    data = data.map{|o| [o.name, o.quantity.to_i, o.tenant_name]}
    render json: data, status: 200
  end

  def search
    field  = search_params[:field].downcase.to_sym
    query  = search_params[:q]
    products  = Product.arel_table
    if search_params[:field] == 'Category'
      @products = Product.joins(product_sub_category: :product_category)
                   .where("product_categories.name ILIKE ?", "%#{query}%")
                   .page(page_params[:page])
                   .per(page_params[:page_size])
      @total    = Product.joins(product_sub_category: :product_category)
                   .where("product_categories.name ILIKE ?", "%#{query}%")
                   .count
    elsif search_params[:field] == 'Sub Category'
      @products = Product.joins(:product_sub_category)
                   .where("product_sub_categories.name ILIKE ?", "%#{query}%")
                   .page(page_params[:page])
                   .per(page_params[:page_size])
      @total    = Product.joins(:product_sub_category)
                   .where("product_sub_categories.name ILIKE ?", "%#{query}%")
                   .count
    elsif search_params[:field] == 'Tenant'
      @products = Product.joins(tenant: :profile)
                   .where("profiles.name ILIKE ?", "%#{query}%")
                   .page(page_params[:page])
                   .per(page_params[:page_size])
      @total    = Product.joins(tenant: :profile)
                   .where("profiles.name ILIKE ?", "%#{query}%")
                   .count       
    else
      @products = Product.where(products[field]
                   .matches("%#{query}%"))
                   .includes(:choices, :product_sub_category)
                   .page(page_params[:page])
                   .per(page_params[:page_size])
      @total    = Product.where(products[field]
                   .matches("%#{query}%"))
                   .count
    end

    respond_with @products
  end

  def update
    encode64
    super
  end

  private
    def product_params
      if current_user.role == 'manager'
        params.require(:product).permit(:name, :picture,
          :description, :picture_base64, :product_sub_category_id, :picture_extension, :active, :tenant_id,
          :price, :sold_out, :serv_category, :serv_sub_category, choices: [:name, :id])
      else
          params.require(:product).permit(:name, :category, :picture, :default_price, :sold_out, :serv_category, :serv_sub_category, :tenant_id)
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

      # product choices
      choice_arr = []
      resource_params[:choices] ||= []
      resource_params[:choices].each do |choice|
        unless choice[:name].blank?
          choice_obj = Choice.find_or_create_by(name: choice[:name])
          choice_arr << choice_obj
        end
      end
      resource_params[:choices] = choice_arr

      #product categories and params
      product_category     = ProductCategory.find_or_create_by(name: resource_params[:serv_category])
      product_sub_category = ProductSubCategory.find_or_create_by(name: resource_params[:serv_sub_category])
      
      if product_sub_category.product_category_id.present?
        if product_sub_category.product_category != product_category
          product_sub_category = ProductSubCategory.create(name: product_sub_category.name, product_category_id: product_category.id)
        end
      else
        product_sub_category.update(product_category_id: product_category.id)
      end

      resource_params[:product_sub_category_id] = product_sub_category.id
      if resource_params[:picture].present?
        resource_params[:picture] = '/uploads/' + resource_params[:picture].split('/')[-1]
      end
      resource_params.delete(:picture_base64)
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
      [:choices, :product_sub_category, :discounts, product_sub_category: :product_category]
    end
end
