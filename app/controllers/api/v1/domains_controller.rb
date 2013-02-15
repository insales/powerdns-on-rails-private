class Api::V1::DomainsController < Api::V1Controller
  inherit_resources
  actions :create, :show, :update, :destroy
  respond_to :json, :xml

  protected
      def resource
        @domain ||= params[:domain_name] ?
          Domain.find_by_name!(params[:domain_name]) :
          Domain.find(params[:id])
      end
end