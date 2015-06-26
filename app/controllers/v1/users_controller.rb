class V1::UsersController < V1::BaseController
  def index
    hash_query_params    = query_params

    if query_params['role'].presence
      hash_query_params['role'] = User.roles[hash_query_params['role']]
    end

    if query_params['role'].presence && query_params['role'] == 'eresto'
      @users = User.where(hash_query_params)
        .includes(attach_includes)
        .page(page_params[:page])
        .per(page_params[:page_size])
    else
      @users = User.where(hash_query_params).where.not(role: 1)
        .includes(attach_includes)
        .page(page_params[:page])
        .per(page_params[:page_size])
    end
    respond_with @users
  end

  private
    def user_params
      params.require(:user)
        .permit(
          :email, :role, :company_id, :outlet_id, :password, 
          profile_attributes: 
            [:name, :phone, :address, :join_at, :contract_until]
          )
    end

    def query_params
      params.require(:filter).permit(:role) rescue {} 
    end

    def attach_includes
      [:profile]
    end
end
