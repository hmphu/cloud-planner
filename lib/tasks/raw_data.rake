namespace :raw_data do
  desc "TODO"
  task aws_instances: :environment do
    # Delete existing data first
    aws = Provider.find_by_name('aws')
    aws.instance_types.delete_all

    # Load new data
    InstanceType.load_aws_data
  end

end
