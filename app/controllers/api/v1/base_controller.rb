class Api::V1::BaseController < ApplicationController
  include PaginationHelper

  skip_before_action :authenticate_user!
  before_action :authenticate_user
  before_action :check_suspended_user

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def authenticate_user
    return if user

    render json: { error: 'Não foi possível autenticar o usuário baseado no token fornecido.' }, status: :unauthorized
  end

  def check_suspended_user
    return unless user.suspended

    render json: { error: 'Sua conta está suspensa. Por favor, contate o administrador.' }, status: :unauthorized
  end

  def not_found
    render json: { error: 'Registro não encontrado' }, status: :not_found
  end
end
