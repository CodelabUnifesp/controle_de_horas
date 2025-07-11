class Api::V1::TeamsController < Api::V1::BaseController
  before_action :team, only: %i[show]

  def index
    scope = TeamsFinder.new(permitted_params).perform
    @teams = paginate(scope:, params: permitted_params)
  end

  def show
    @team
  end

  private

  def permitted_params
    params.permit(
      :name,
      :all_records,
      :page,
      :sort_by,
      :sort_order,
      member_ids: []
    )
  end

  def team
    @team ||= Team.includes(:members, :memberships).find(params[:id])
  end
end
