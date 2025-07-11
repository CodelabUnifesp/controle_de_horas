json.records do
  json.array! @teams do |team|
    json.partial! 'api/v1/models/team', formats: [:json], resource: team
    json.member_count team.member_count.to_i
  end
end

json.total_pages @teams.try(:total_pages) || 1
json.current_page @teams.try(:current_page) || 1
json.total_count @teams.try(:total_count) || @teams.count
