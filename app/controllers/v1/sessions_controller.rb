class V1::SessionsController < ApplicationController
  def create
    user = User.where(username_params).first
    if user
      if user.valid_password?(password_params[:password])
        now = (DateTime.now + 30.minutes).to_i
        string = user.token + '||' + now.to_s
        string = AESCrypt.encrypt string, '\n'
        render json: {token:  Base64.urlsafe_encode64(string)}
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
