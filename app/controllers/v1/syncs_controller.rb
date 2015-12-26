class V1::SyncsController < V1::BaseController

	# from cloud
  def import_sales
  	Synchronize.import_sales(params[:payments])
  end

  # from local
  def export_sales
  	Synchronize.export_sales(params[:payments])
  end

  # from both 
  def import_data
  	Synchronize.import_data
  end

  # from both
  def export_data
  	Synchronize.export_data
  end
end