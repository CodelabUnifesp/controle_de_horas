json.records do
  json.array! @members do |member|
    json.partial! 'api/v1/models/member', formats: [:json], resource: member

    json.teams do
      json.array! member.teams do |team|
        json.partial! 'api/v1/models/team', formats: [:json], resource: team
      end
    end
  end
end

json.total_pages @members.try(:total_pages) || 1
json.current_page @members.try(:current_page) || 1
json.total_count @members.try(:total_count) || @members.count
