class V1::TablesController < V1::BaseController
	private
    def table_params
      params.require(:table).permit(:name)
    end

    def query_params
      params.permit(:name)
    end

    def attach_includes
    	[:parts]
    end
end
