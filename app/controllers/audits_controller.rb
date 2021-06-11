class AuditsController < ApplicationController

  before_action do
    unless current_user.admin?
      redirect_to root_url
    end
  end

  def index
    @audits = Audit.reorder(id: :desc).includes(:user, auditable: :domain).page(params[:page])
  end

  # Retrieve the audit details for a domain
  def domain
    @domain = Domain.user( current_user ).find( params[:id] )
  end

end
