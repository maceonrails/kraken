class V1::BaseController < ApplicationController
  include Devise::Controllers::SignInOut

  before_action :authenticate
  before_action :set_resource, only: [:destroy, :show, :update]
  # before_action :set_token_response

  # POST /api/sync
  def sync
    if outlet_params
      Outlet.destroy_all if Outlet.all.count > 1
      outlet = Outlet.find_or_initialize_by(id: outlet_params[:id])
      outlet.update(outlet_params)
    end

    ProductCategory.sync(params[:product_categories]) if params[:product_categories]
    ProductSubCategory.sync(params[:product_sub_categories]) if params[:product_sub_categories]
    Product.sync(params[:products]) if params[:products]
    Discount.sync params[:discounts] if params[:discounts]
    create_user sync_params if sync_params[:users]
    render json: { message: 'Data syncronized' }, status: 201
  end

  # POST /api/{plural_resource_name}
  def create
    set_resource(resource_class.new(resource_params))

    if get_resource.save
      render :show, status: :created
    else
      render json: get_resource.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/{plural_resource_name}/1
  def destroy
    get_resource.destroy
    head :no_content
  end

  def search
    field = search_params[:field].downcase.to_sym
    query = search_params[:q]

    plural_resource_name = "@#{resource_name.pluralize}"
    tables    = resource_class.arel_table
    resources = resource_class.where(tables[field]
                  .matches("%#{query}%"))
                  .page(page_params[:page])
                  .per(page_params[:page_size])

    @total    = resource_class.where(tables[field]
                  .matches("%#{query}%"))
                  .count

    resources = resources.includes(attach_includes) if attach_includes

    instance_variable_set(plural_resource_name, resources)
    respond_with instance_variable_get(plural_resource_name)
  end

  # GET /api/{plural_resource_name}
  def index
    plural_resource_name = "@#{resource_name.pluralize}"
    resources = resource_class.where(query_params)
                              .page(page_params[:page])
                              .per(page_params[:page_size])

    resources = resources.includes(attach_includes) if attach_includes

    instance_variable_set(plural_resource_name, resources)
    respond_with instance_variable_get(plural_resource_name)
  end

  # GET /api/{plural_resource_name}/all
  def all
    plural_resource_name = "@#{resource_name.pluralize}"
    resources = resource_class.where(query_params)
    resources = resources.includes(attach_includes) if attach_includes

    instance_variable_set(plural_resource_name, resources)
    respond_with(instance_variable_get(plural_resource_name)) do |format|
      format.json { render :index }
    end
  end

  # GET /api/{plural_resource_name}/1
  def show
    respond_with get_resource
  end

  # PATCH/PUT /api/{plural_resource_name}/1
  def update
    resource_params[:updated_by] = current_user.id unless resource_name == 'user'
    if get_resource.update(resource_params)
      render :show
    else
      render json: get_resource.errors, status: :unprocessable_entity
    end
  end

  def me
    @user = current_user
  end

  private
    def outlet_params
      params.require(:outlet).permit(:id, :name, :email, :phone, :mobile, :address, :taxs).tap do |whitelisted|
        whitelisted[:taxs] = params[:outlet][:taxs]
      end rescue nil
    end

    def sync_params
      params.permit(:users).tap do |whitelisted|
        whitelisted[:users] = params[:users]
      end
    end

    def user_params(user)
      user.permit!
    end

    def create_user(sync_params)
      users = sync_params[:users]
      ids   = users.collect{|u| u[:id]}
      User.where.not(role: 3).where.not(id: ids).destroy_all
      outlet = Outlet.first
      users.each do |user|
        user[:outlet] = outlet
        if !User.where(id: user[:id]).blank?
          User.update user[:id], role: user[:role]
        else
          obj          = User.new(user_params user)
          obj.password = 'password'
          obj.save
        end
      end
    end

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end

    def set_token_response
      if current_user
        now    = (DateTime.now + 30.minutes).to_i
        string = current_user.token + '||' + now.to_s
        string = AESCrypt.encrypt string, '\n'
        response.headers['X-Token'] = Base64.urlsafe_encode64(string)
      end
    end

    def authenticate
      user_token = params['token'].presence
      user = nil

      if user_token
        encrypted  = Base64.urlsafe_decode64(user_token)
        decrypted  = AESCrypt.decrypt encrypted, '\n'
        user       = User.find_by_token(decrypted.to_s)
      end

      if user
        # We are passing store false, so the user is not actually stored in the session
        sign_in user, store: false
      else
        warden.custom_failure!
        message = 'You are not authorized to access this data'
        json_error message, 401
      end
    end

    # Returns the relation to included in search
    # Override this method in each API controllern
    # @return [Array]
    def attach_includes
      nil
    end

    # Returns the resource from the created instance variable
    # @return [Object]
    def get_resource
      instance_variable_get("@#{resource_name}")
    end

    # Returns the allowed parameters for searching
    # Override this method in each API controller
    # to permit additional parameters to search on
    # @return [Hash]
    def query_params
      {}
    end

    # Returns the allowed parameters for pagination
    # @return [Hash]
    def page_params
      params.permit(:page, :page_size)
    end

    # The resource class based on the controller
    # @return [Class]
    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    # The singular name for the resource class based on the controller
    # @return [String]
    def resource_name
      @resource_name ||= self.controller_name.singularize
    end

    # Only allow a trusted parameter "white list" through.
    # If a single resource is loaded for #create or #update,
    # then the controller for the resource must implement
    # the method "#{resource_name}_params" to limit permitted
    # parameters for the individual model.
    def resource_params
      @resource_params ||= self.send("#{resource_name}_params")
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource(resource = nil)
      resource ||= resource_class.find(params[:id])
      instance_variable_set("@#{resource_name}", resource)
    end
end
