json.extract! instance_type, :id, :provider_id, :region_id, :machine_type_id, :os_type, :price, :price_1y, :created_at, :updated_at
json.url instance_type_url(instance_type, format: :json)