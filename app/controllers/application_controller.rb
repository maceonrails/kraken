class ApplicationController < ActionController::Base
  include ActionController::ImplicitRender
  respond_to :json

  rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
    message = parameter_missing_exception.param.to_s.capitalize + " parameter is required"
    json_error message, 400
  end

  rescue_from OpenSSL::Cipher::CipherError do 
    message = 'You are not authorized to access this data'
    json_error message, 401
  end

  protected 
    def json_error(message, code)
      json = { message: message }
      render json: json, :status => code
    end
end
