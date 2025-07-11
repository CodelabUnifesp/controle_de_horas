class MembersFinder
  def initialize(params)
    @params = params
    @active = @params[:active]
    @name = @params[:name]
    @external_id = @params[:external_id]
    @team_ids = @params[:team_ids]
    @sort_by = @params[:sort_by] || 'name'
    @sort_order = @params[:sort_order] || 'asc'
    @with_hours = @params[:with_hours]
  end

  def perform
    members = Member.all
    members = apply_filters(members)
    members = add_hours_subqueries(members) if @with_hours
    members = members.includes(:teams)
    apply_sorting(members)
  end

  private

  def apply_filters(scope)
    scope = filter_by_name(scope)
    scope = filter_by_external_id(scope)
    scope = filter_by_active(scope)
    filter_by_teams(scope)
  end

  def filter_by_name(scope)
    return scope if @name.blank?

    scope.where('members.name ILIKE ?', "%#{@name}%")
  end

  def filter_by_external_id(scope)
    return scope if @external_id.blank?

    scope.where('members.external_id ILIKE ?', "%#{@external_id}%")
  end

  def filter_by_active(scope)
    return scope if @active.nil?

    active_value = case @active.to_s.downcase
                   when 'true', '1' then true
                   when 'false', '0' then false
                   else return scope
                   end

    scope.where(members: { active: active_value })
  end

  def filter_by_teams(scope)
    return scope if @team_ids.blank?

    team_ids = Array.wrap(@team_ids).map(&:to_i)
    scope.joins(:teams).where(teams: { id: team_ids }).distinct
  end

  def add_hours_subqueries(scope)
    scope.select(
      'members.*',
      hours_count_subquery,
      hours_sum_subquery
    )
  end

  def hours_count_subquery
    '(SELECT COALESCE(COUNT(events.id), 0) FROM event_assignments ' \
    'LEFT JOIN events ON events.id = event_assignments.event_id ' \
    'WHERE event_assignments.member_id = members.id) AS event_count'
  end

  def hours_sum_subquery
    '(SELECT COALESCE(SUM(events.duration_seconds), 0) FROM event_assignments ' \
    'LEFT JOIN events ON events.id = event_assignments.event_id ' \
    'WHERE event_assignments.member_id = members.id) AS total_seconds'
  end

  def apply_sorting(scope)
    case @sort_by
    when 'name'
      scope.order('members.name' => sort_direction)
    when 'created_at'
      scope.order('members.created_at' => sort_direction)
    when 'total_hours'
      @with_hours ? apply_hours_sorting(scope) : scope.order('members.name' => :asc)
    else
      scope.order('members.name' => :asc)
    end
  end

  def apply_hours_sorting(scope)
    hours_sorting_sql = '(SELECT COALESCE(SUM(events.duration_seconds), 0) ' \
                       'FROM event_assignments ' \
                       'LEFT JOIN events ON events.id = event_assignments.event_id ' \
                       'WHERE event_assignments.member_id = members.id)'

    scope.order(Arel.sql("#{hours_sorting_sql} #{sort_direction.to_s.upcase}"))
  end

  def sort_direction
    @sort_order == 'desc' ? :desc : :asc
  end
end
