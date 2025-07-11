json.id resource.id
json.name resource.name
json.email resource.email
json.pix_key resource.pix_key
json.external_id resource.external_id
json.active resource.active
json.disabled_at resource.disabled_at
json.created_at resource.created_at
json.updated_at resource.updated_at

if resource.respond_to?(:total_seconds)
  json.total_seconds resource.total_seconds.to_i
  json.event_count resource.event_count.to_i
end
