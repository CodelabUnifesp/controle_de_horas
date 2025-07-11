json.record do
  json.partial! 'api/v1/models/member', formats: [:json], resource: @member
end

json.teams do
  json.array! @member.teams do |team|
    json.partial! 'api/v1/models/team', formats: [:json], resource: team
  end
end

json.memberships do
  json.array! @member.memberships do |membership|
    json.partial! 'api/v1/models/membership', formats: [:json], resource: membership
  end
end
