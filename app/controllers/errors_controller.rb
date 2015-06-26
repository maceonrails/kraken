class ErrorsController < ApplicationController
  def catch_404
    json_error "Oops, its looking like you may have taken a wrong turn.", 404 
  end
end
