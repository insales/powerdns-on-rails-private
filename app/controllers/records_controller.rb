class RecordsController < InheritedResources::Base
  belongs_to :domain
  respond_to :xml, :json, :js

  before_action :restrict_token_movements, :except => [:create, :update, :destroy]

  rescue_from AuthToken::Denied do
    render :text => t(:message_token_not_authorized), :status => 403
  end

  def resource_params
    params.require(:record).permit(
      :domain_id,
      :name,
      :content,
      :ttl,
      :prio,
      :change_date,
      :disabled,
      :ordername,
      :auth
    )
  end

  def create
    record_type = params[:record][:type].downcase
    if record_type == 'loc'
      @record = parent.build_loc_record(resource_params)
    else
      @record = parent.send(:"#{record_type}_records").new(resource_params)
    end

    if current_token && !current_token.allow_new_records? &&
        !current_token.can_add?( @record )
      render :text => t(:message_token_not_authorized), status: :forbidden
      return
    end

    if @record.save
      # Give the token the right to undo what it just did
      if current_token
        current_token.can_change @record
        current_token.remove_records = true
        current_token.save
      end
    end

    create!
  end

  def update
    if current_token && !current_token.can_change?( resource )
      render text: t(:message_token_not_authorized), status: :forbidden
      return
    end
    update!
  end

  def destroy
    if current_token && !current_token.can_remove?( resource )
      render text: t(:message_token_not_authorized), status: :forbidden
      return
    end
    destroy! do |format|
      format.html { redirect_to parent }
    end
  end

  # Non-CRUD methods
  def update_soa
    @domain = parent
    @domain.soa_record.update_attributes( params[:soa] )
  end

  protected
    def parent
      if token_user?
        if current_token.domain_id != params[:domain_id]
          raise AuthToken::Denied
        end
        current_token.domain
      else
        Domain.user( current_user ).find( params[:domain_id] )
      end
    end

    def collection
      parent.records
    end

    def resource
      collection.find params[:id]
    end

    def restrict_token_movements
      return true unless current_token
      render text: t(:message_token_not_authorized), status: :forbidden
      return false
    end
end
