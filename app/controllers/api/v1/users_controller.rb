class Api::V1::UsersController < Api::V1::BaseController
  def my_user
    render json: { record: user.as_json }
  end

  def update_my_user
    result = update_user_attributes
    if result
      render json: { record: user.as_json }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def update_user_attributes
    if user_params[:password].blank?
      user.update(user_params.except(:password, :password_confirmation, :current_password))
    else
      user.update_with_password(user_params)
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end
