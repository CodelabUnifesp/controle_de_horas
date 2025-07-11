class EventsFinder
  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def perform
    scope = Event.left_joins(:teams).includes(:teams, :members)
    scope = filter_by_team(scope)
    scope = filter_by_member(scope)
    scope = filter_by_search(scope)
    scope = filter_by_occurred_range(scope)
    scope = scope.distinct
    sort(scope)
  end

  private

  def filter_by_team(scope)
    return scope if params[:team_ids].blank?

    scope.joins(:event_teams).where(event_teams: { team_id: params[:team_ids] })
  end

  def filter_by_member(scope)
    return scope if params[:member_id].blank?

    scope.joins(:event_assignments).where(event_assignments: { member_id: params[:member_id] })
  end

  def filter_by_search(scope)
    return scope if params[:search].blank?

    scope.where('events.title ILIKE ?', "%#{params[:search]}%")
  end

  def filter_by_occurred_range(scope)
    if params[:occurred_from].present?
      scope = scope.where('events.occurred_at >= ?',
                          Date.parse(params[:occurred_from]))
    end
    if params[:occurred_to].present?
      scope = scope.where('events.occurred_at <= ?',
                          Date.parse(params[:occurred_to]).end_of_day)
    end
    scope
  end

  def sort(scope)
    sort_by = params[:sort_by]
    sort_order = params[:sort_order] || 'desc'

    case sort_by
    when 'title', 'duration_seconds', 'occurred_at'
      scope.order("events.#{sort_by} #{sort_order}")
    when 'team_name'
      scope.select('events.*, teams.name as team_name_sort').order("teams.name #{sort_order}")
    when 'members_count'
      count = 'SELECT COUNT(*) FROM event_assignments WHERE event_assignments.event_id = events.id'
      scope.select("events.*, (#{count}) as members_count_sort").order("(#{count}) #{sort_order}")
    else
      scope.order('events.occurred_at desc')
    end
  end
end
