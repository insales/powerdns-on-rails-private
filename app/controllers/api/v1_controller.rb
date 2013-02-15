class Api::V1Controller < ActionController::Base
  before_filter :authenticate_api_v1_api_client!
end