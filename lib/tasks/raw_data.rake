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
    InstanceType.where(provider: 'aws').delete_all
    InstanceType.load_aws_data
  end

  desc "load AWS EC2 instance_types from csv"
  task aws_csv: :environment do
    InstanceType.where(provider: 'aws').delete_all
    InstanceType.load_aws_csv
  end

  desc "load Azure Instance types"
  task azure_instances: :environment do
    old_count = InstanceType.where(provider: 'azure').count.to_s
    InstanceType.where(provider: 'azure').delete_all
    puts old_count + " deleted"

    MachineType.where(provider_name: 'azure').delete_all

    InstanceType.load_azure_data
    puts InstanceType.where(provider: 'azure').count.to_s + " created" 
  end
end
