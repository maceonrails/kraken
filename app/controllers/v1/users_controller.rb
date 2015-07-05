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

  def search
    field  = search_params[:field].downcase.to_sym
    query  = search_params[:q]
    users  = User.arel_table
    if (search_params[:field] == 'Name')
      @users = User.joins(:profile)
                   .where("profiles.name LIKE ?", "%#{query}%")
                   .page(page_params[:page])
                   .per(page_params[:page_size])
      @total = User.joins(:profile)
                   .where("profiles.name LIKE ?", "%#{query}%")
                   .count
    else
      @users = User.where(users[field]
                   .matches("%#{query}%"))
                   .page(page_params[:page])
                   .per(page_params[:page_size])
      @total = User.where(users[field]
                   .matches("%#{query}%"))
                   .count
    end

    respond_with @users
  end

  private
    def user_params
      if !params[:user][:password].presence || params[:user][:password].blank?
        params[:user].delete(:password)
      end

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

    def search_params
      params.except(:format, :token, :page).permit(:field, :q)
    end
end
