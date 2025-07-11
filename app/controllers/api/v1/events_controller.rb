class Api::V1::EventsController < Api::V1::BaseController
  before_action :event, only: %i[destroy update]
  before_action :check_duration, only: %i[create update]

  def index
    scope = EventsFinder.new(permitted_params).perform
    @events = paginate(scope:, params: permitted_params)
  end

  def show
    event
  end

  def create
    @event = Event.new(permitted_params.except(:member_ids, :team_ids))

    ActiveRecord::Base.transaction do
      if add_teams_to_event && @event.save && manage_members
        head :created
      else
        render_error
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    @event.destroy! and head :ok
  end

  def update
    @event.update(permitted_params.except(:member_ids, :team_ids))

    ActiveRecord::Base.transaction do
      if @event.save && manage_teams && manage_members
        head :ok
      else
        render_error
        raise ActiveRecord::Rollback
      end
    end
  end

  private

  def permitted_params
    params.permit(
      :duration_seconds,
      :team_id,
      :member_id,
      :title,
      :description,
      :page,
      :sort_by,
      :sort_order,
      :search,
      :occurred_at,
      :occurred_from,
      :occurred_to,
      member_ids: [],
      team_ids: []
    )
  end

  def event
    @event ||= Event.includes(:teams, :members).find(params[:id])
  end

  def render_error
    render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
  end

  def add_teams_to_event
    team_ids = Array.wrap(permitted_params[:team_ids]).map(&:to_i)
    teams = Team.where(id: team_ids)
    @event.teams = teams
    true
  end

  def manage_teams
    current_team_ids = @event.team_ids
    new_team_ids = Array.wrap(permitted_params[:team_ids]).map(&:to_i)

    return true if current_team_ids.sort == new_team_ids.sort

    @event.event_teams.where(team_id: current_team_ids - new_team_ids)&.each(&:destroy)
    (new_team_ids - current_team_ids).each { |id| @event.event_teams.create!(team_id: id) }

    @event.reload
  end

  def manage_members
    current_member_ids = @event.member_ids
    new_member_ids = Array.wrap(permitted_params[:member_ids]).map(&:to_i)

    @event.event_assignments.where(member_id: current_member_ids - new_member_ids)&.each(&:destroy)
    (new_member_ids - current_member_ids).each { |id| @event.event_assignments.create!(member_id: id) }

    @event.reload
  end

  def check_duration
    return if possible_duration_seconds.include?(permitted_params[:duration_seconds]&.to_i)

    render json: { error: 'Duração inválida' }, status: :unprocessable_entity
  end

  def possible_duration_seconds
    [
      15.minutes.to_i,
      30.minutes.to_i,
      1.hour.to_i,
      2.hours.to_i,
      3.hours.to_i,
      4.hours.to_i
    ]
  end
end
