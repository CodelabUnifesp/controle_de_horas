class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(_resource, _opts = {})
    if current_user
      render json: {
        message: 'You are logged in.',
        user: current_user
      }, status: :ok
    else
      head :unauthorized
    end
  end

  def respond_to_on_destroy
    head fetch_user_from_token.present? ? :ok : :unauthorized
  end

  def fetch_user_from_token
    UserFinder.new(request.headers['Authorization']).perform
  rescue JWT::ExpiredSignature
    render json: { error: 'Token expired' }, status: :unauthorized
  end
end
