class InstanceType < ApplicationRecord
  belongs_to :provider
  belongs_to :region
  belongs_to :machine_type

  enum os_type: [:linux, :windows, :windows_sql]
end
