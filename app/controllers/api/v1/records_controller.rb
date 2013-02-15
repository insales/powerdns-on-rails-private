class Api::V1::RecordsController < Api::V1Controller
  inherit_resources
  actions :index, :create, :show, :update, :destroy
  respond_to :json, :xml
  belongs_to :domain

  def create
    @record = parent.send( "#{params[:record][:type].downcase}_records".to_sym ).new params[:record]
    create!
  end

  def delete_all
    parent.records.where('type != ?', 'SOA').delete_all
    respond_to do |format|
      format.json { head :no_content }
      format.xml  { head :no_content }
    end
  rescue => e
    respond_to do |format|
      format.json { render json: {error: e.message}, status: :unprocessible_entity }
      format.xml  { render xml:  {error: e.message}, status: :unprocessible_entity }
    end
  end

  private
    def evaluate_parent(parent_symbol, parent_config, chain = nil)
      @domain ||= params[:domain_name] ?
        Domain.find_by_name!(params[:domain_name]) :
        Domain.find!(params[:id])
    end
end