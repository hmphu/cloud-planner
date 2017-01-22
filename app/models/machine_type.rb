require 'httparty'

class MachineType < ApplicationRecord
  belongs_to :provider
  
  def self.load_aws_machine_types
    aws_id = Provider.find_by_name('aws').id
    @machine_types = HTTParty.get('http://localhost:3000/instances/machine_types')
    @machine_types.each do |m|
      create name: m[0],
             core_count: m[1],
             memory_size: m[2],
             provider_id: aws_id
    end
  end

end
