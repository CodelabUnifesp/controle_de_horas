json.record do
  json.partial! 'api/v1/models/event', formats: [:json], resource: @event
end
