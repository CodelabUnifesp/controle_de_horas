json.id resource.id
json.title resource.title
json.description resource.description
json.duration_seconds resource.duration_seconds
json.team_ids resource.team_ids
json.members_count resource.members.size
json.occurred_at resource.occurred_at
json.created_at resource.created_at
json.updated_at resource.updated_at

json.teams do
  json.array! resource.teams do |team|
    json.partial! 'api/v1/models/team', formats: [:json], resource: team
  end
end

json.members do
  json.array! resource.members do |member|
    json.partial! 'api/v1/models/member', formats: [:json], resource: member
  end
end
