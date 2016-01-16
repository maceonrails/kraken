class V1::SyncsController < V1::BaseController
  skip_before_action :authenticate
  skip_before_action :set_token_response

  def import_from_cloud
    params = JSON.parse request.body.read
    status = Synchronize.import_from_cloud params
    if status
      render json: { message: "Import successful"}, status: 201
    else
      render json: { message: "Import order failed" }, status: 409
    end
  end
end