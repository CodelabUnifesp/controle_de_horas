class Api::V1::SuperAdmin::BaseController < Api::V1::BaseController
  before_action :check_super_admin

  private
  
  def check_super_admin
    unless user.super_admin
      render json: { error: "Você deve ser um usuário super admin para acessar esta área." }, status: :unauthorized
    end
  end
end
