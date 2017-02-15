class Provider < ApplicationRecord
  has_many :regions
  has_many :machine_types

  def self.load_providers
    return "Already Loaded" if self.count > 0

    ['aws', 'azure', 'google'].each do |p|
      create name: p
    end
  end

  def self.monthly_hours(name)
    hours = {
      'aws' => 732,
      'azure' => 744,
    }
    return hours[name]
  end
end
