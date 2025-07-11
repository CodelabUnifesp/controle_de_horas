json.record do
  json.partial! 'api/v1/models/team', formats: [:json], resource: @team
end

json.members do
  json.array! @team.members do |member|
    json.partial! 'api/v1/models/member', formats: [:json], resource: member
  end
end

json.memberships do
  json.array! @team.memberships do |membership|
    json.partial! 'api/v1/models/membership', formats: [:json], resource: membership
  end
end
