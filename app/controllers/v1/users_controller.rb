class V1::UsersController < V1::ApiController
  def details
    json_response current_user, needs_subscription: false
  end
end
