class DashboardController < ApplicationController

  def index
    @latest_domains_limit = 5
    @latest_domains = Domain.unscoped.user(current_user).order('created_at DESC').limit(@latest_domains_limit)
  end
end
