class ApplicationController < ActionController::Base
  private

    def require_admin
      raise ActionController::RoutingError, "Not Found"
    end
end
