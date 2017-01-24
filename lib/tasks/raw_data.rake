namespace :raw_data do
  desc "find Byol"
  task find_byol: :environment do
    InstanceType.find_byol
  end

  desc "load Provider"
  task load_providers: :environment do
    Provider.delete_all
    Provider.load_providers
  end

  desc "load AWS machine_types and regions"
  task aws_machines_regions: :environment do
    MachineType.load_aws_machine_types
    Region.load_aws_regions
  end


  desc "load AWS EC2 instance_types"
  task aws_instances: :environment do
    # Delete existing data first
    aws = Provider.find_by_name('aws')
    aws.instance_types.delete_all

    # Load new data
    InstanceType.load_aws_data
  end

end
