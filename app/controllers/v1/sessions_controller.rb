class V1::SessionsController < ApplicationController
	def create
    user = User.where(username_params).first
    if user
      if user.valid_password?(password_params[:password])
        now = (DateTime.now + 60.minutes).to_i
        string = user.token + '||' + now.to_s
        render json: {token:  AESCrypt.encrypt(string, '\n')}
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
