class Api::V1::MembersController < Api::V1::BaseController
  before_action :member, only: %i[show]

  def index
    scope = MembersFinder.new(permitted_params).perform.includes(:teams)
    scope = scope.active if permitted_params[:all_records] == 'true'
    @members = paginate(scope:, params: permitted_params)
  end

  def show
    @member
  end

  private

  def permitted_params
    params.permit(:name, :pix_key, :external_id, :all_records, :page, :active,
                  :sort_by, :sort_order, team_ids: [])
  end

  def member
    @member ||= Member.active.includes(:memberships, :teams).find(params[:id])
  end
end
