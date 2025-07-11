json.records do
  json.array! @events do |event|
    json.partial! 'api/v1/models/event', formats: [:json], resource: event
  end
end

json.total_pages @events.try(:total_pages) || 1
json.current_page @events.try(:current_page) || 1
json.total_count @events.try(:total_count) || @events.count
