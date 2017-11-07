class Api::V1::UsersController < Api::V1::ApiController
  def details
    render json: current_user
  end
end
