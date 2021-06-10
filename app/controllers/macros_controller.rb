class MacrosController < InheritedResources::Base

  protected

  def resource
    @macro = Macro.user( current_user ).find(params[:id])
  end

  def collection
    @macros = Macro.user(current_user)
  end

  def macro_params
    fields = [:name, :description, :active]
    fields << :user_id if current_user.admin?

    params.require(:macro).permit(*fields)
  end

  public

  def new
    new! do |format|
      format.html { render :action => :edit }
    end
  end

  def create
    create! do |success, failure|
      failure.html { render :action => :edit }
    end
  end

  def create_resource(macro)
    macro.user = macro_owner_from_params
    super
  end

  def update_resource(macro, attributes)
    super
    macro.user = macro_owner_from_params
  end

  protected
  def macro_owner_from_params
    current_user.admin? ? User.find(params[:macro][:user_id].presence || current_user.id) : current_user
  end
end
