class Provider < ApplicationRecord
  has_many :regions
  has_many :machine_types
  has_many :instance_types
end
