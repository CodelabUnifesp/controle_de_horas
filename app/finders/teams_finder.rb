class TeamsFinder
  def initialize(params)
    @params = params
  end

  def perform
    teams = base_scope
    teams = filter_by_name(teams)
    teams = with_member_count(teams)
    apply_sorting(teams)
  end

  private

  def base_scope
    Team.all
  end

  def filter_by_name(scope)
    return scope if @params[:name].blank?

    scope.where('teams.name ILIKE ?', "%#{@params[:name]}%")
  end

  def with_member_count(scope)
    scope
      .left_joins(:memberships).distinct
      .select('teams.*, COUNT(memberships.id) AS member_count')
      .group('teams.id')
  end

  def apply_sorting(scope)
    sort_by = @params[:sort_by]&.to_s
    sort_order = @params[:sort_order]&.to_s == 'desc' ? 'desc' : 'asc'

    case sort_by
    when 'name'
      scope.order("teams.name #{sort_order}")
    when 'member_count'
      scope.order("COUNT(memberships.id) #{sort_order}")
    else
      scope.order('teams.name asc')
    end
  end
end
