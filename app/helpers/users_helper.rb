# frozen_string_literal: true
module UsersHelper
  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

end
