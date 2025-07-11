class Api::V1::SuperAdmin::TeamsController < Api::V1::SuperAdmin::BaseController
  before_action :team, only: %i[destroy update show]

  def index
    scope = TeamsFinder.new(permitted_params).perform
    @teams = paginate(scope:, params: permitted_params)
  end

  def show
    @team
  end

  def create
    @team = Team.new(permitted_params.except(:member_ids))
    @team.save && manage_members || render_error
  end

  def destroy
    @team.destroy! and head :ok
  end

  def update
    ActiveRecord::Base.transaction do
      @team.update!(permitted_params.except(:member_ids))
      manage_members
      head :ok
    rescue ActiveRecord::RecordInvalid
      render_error
      raise ActiveRecord::Rollback
    end
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

  def render_error
    render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
  end

  def manage_members
    current_member_ids = @team.member_ids
    new_member_ids = Array.wrap(permitted_params[:member_ids]).map(&:to_i)

    @team.memberships.where(member_id: current_member_ids - new_member_ids).find_each(&:destroy)
    (new_member_ids - current_member_ids).each { |id| @team.memberships.create!(member_id: id) }

    @team.reload
  end
end
