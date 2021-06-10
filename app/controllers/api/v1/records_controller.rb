class Api::V1::RecordsController < Api::V1Controller
  inherit_resources
  actions :index, :create, :show, :update, :destroy
  respond_to :json, :xml
  belongs_to :domain

  def create
    return render_error('Type not set') unless params[:record].try(:[], :type)
    return render_error('Invalid type') unless Record.record_types.include?(params[:record][:type])

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
    render_error(e.message)
  end

  private

  def evaluate_parent(parent_symbol, parent_config, chain = nil)
    @domain ||= params[:domain_name] ?
      Domain.find_by_name!(params[:domain_name]) :
      Domain.find(params[:domain_id])
  end

  def render_error(message)
    respond_to do |format|
      format.json { render json: {error: message}, status: :unprocessable_entity }
      format.xml  { render xml:  {error: message}, status: :unprocessable_entity }
    end
  end
end