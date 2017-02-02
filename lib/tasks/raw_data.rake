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
    p = Provider.find_by_name('aws')
    p.instance_types.delete_all
    InstanceType.load_aws_data
  end

  desc "load Azure Instance types"
  task azure_instances: :environment do
    p = Provider.find_by_name('azure')
    p.instance_types.delete_all
    InstanceType.load_azure_date
end
