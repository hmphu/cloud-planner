class MachineType < ApplicationRecord
  belongs_to :provider
  
  def self.load_aws_machine_types
    aws = Provider.find_by_name('aws').id
    aws.machine_types.delete_all
    @machine_types = HTTParty.get('http://localhost:3000/instances/machine_types')
    @machine_types.each do |m|
      create name: m[0],
             core_count: m[1],
             memory_size: m[2],
             provider_id: aws.id
    end
  end

end
