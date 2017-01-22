class Provider < ApplicationRecord
  has_many :regions
  has_many :machine_types
  has_many :instance_types



  def self.load_providers
    ['aws', 'azure', 'google'].each do |p|
      create name: p
    end
  end

end
