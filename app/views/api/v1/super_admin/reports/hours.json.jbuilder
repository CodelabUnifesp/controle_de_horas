json.record do
  json.id @member_with_hours[:id]
  json.name @member_with_hours[:name]
  json.created_at @member_with_hours[:created_at]
  json.disabled_at @member_with_hours[:disabled_at]
  json.total_seconds @member_with_hours[:total_seconds]
  json.event_count @member_with_hours[:event_count]

  json.real do
    json.total_weeks @member_with_hours[:real][:total_weeks]
    json.average_hours_per_week @member_with_hours[:real][:average_hours_per_week]
    json.first_event_at @member_with_hours[:real][:first_event_at]
    json.last_event_at @member_with_hours[:real][:last_event_at]
  end

  json.ideal do
    json.total_weeks @member_with_hours[:ideal][:total_weeks]
    json.average_hours_per_week @member_with_hours[:ideal][:average_hours_per_week]
    json.first_event_at @member_with_hours[:ideal][:first_event_at]
    json.last_event_at @member_with_hours[:ideal][:last_event_at]
  end

  json.events do
    json.array! @member_events do |event|
      json.id event.id
      json.title event.title
      json.description event.description
      json.duration_seconds event.duration_seconds
      json.occurred_at event.occurred_at
      json.teams do
        json.array! event.teams do |team|
          json.id team.id
          json.name team.name
        end
      end
    end
  end
end
