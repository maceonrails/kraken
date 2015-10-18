class V1::SessionsController < ApplicationController
  def create
    user = User.where(username_params).first
    if user
      if user.valid_password?(password_params[:password])
        user.start_login = DateTime.now
        user.save
        string = user.token
        string = AESCrypt.encrypt string, '\n'
        render json: { token:  Base64.urlsafe_encode64(string), role: user.role, id: user.id, name: user.profile.try(:name) || user.email }
      else
        json_error 'Password didn\'t correct', 400
      end
    else
      json_error 'User not registered', 404
    end
  end

  private
    def username_params
      params.require(:user).permit(:email)
    end

    def password_params
      params.require(:user).permit(:password)
    end
end
