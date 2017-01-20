json.extract! machine_type, :id, :name, :core_count, :memory_size, :provider_id, :created_at, :updated_at
json.url machine_type_url(machine_type, format: :json)