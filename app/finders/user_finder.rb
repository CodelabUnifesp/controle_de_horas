class UserFinder
  attr_reader :jwt_token

  def initialize(jwt_token)
    @jwt_token = jwt_token
  end

  def perform
    token = jwt_token&.gsub(/^Bearer\s/, '')
    return if token.blank?

    jwt_payload = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY']).first
    user_id = jwt_payload['sub']
    User.find(user_id.to_s)
  end
end
