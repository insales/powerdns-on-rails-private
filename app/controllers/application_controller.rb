class ApplicationController < ActionController::Base
  protect_from_forgery

  # All pages require a login...
  before_filter :authenticate_user!

  helper_method :current_token
  helper_method :token_user?

  class << self
    def allow_admin_only!
      before_filter do
        redirect_to root_url unless current_user.admin?
      end
    end
  end

  protected
    # stubs
    def current_token
      nil
    end

    def token_user
      false
    end
end
