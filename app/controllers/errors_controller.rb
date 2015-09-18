class ErrorsController < ApplicationController
  def catch_404
    json_error "Oops, its looking like you may have taken a wrong turn.", 404 
  end

  def manager
    render :file => 'public/manager/index.html'
  end

  def kitchen
    render :file => 'public/kitchen/index.html'
  end
end
