require 'httparty'

class Region < ApplicationRecord
  belongs_to :provider

  def self.load_aws_regions
    # Global Areas : US, EU, AP(Asia Pacific), 
    #                SA(Aouth America), NA(North America) 
    name_mapping = {
      "US East (Ohio)" => "us_ohio",
      "EU (Frankfurt)" => "eu_frankfurt",
      "Asia Pacific (Seoul)" => "ap_seoul",
      "Asia Pacific (Singapore)" => "ap_singapore",
      "Asia Pacific (Sydney)" => "ap_sydney",
      "US West (Oregon)" => "us_oregon",
      "South America (Sao Paulo)" => "sa_saopaulo",
      "US East (N. Virginia)" => "us_virginia",
      "US West (N. California)" => "us_california",
      "AWS GovCloud (US)" => "us_gov",
      "EU (Ireland)" => "eu_ireland",
      "Asia Pacific (Tokyo)" => "ap_tokyo",
      "Asia Pacific (Mumbai)" => "ap_mumbai",
      "Canada (Central)" => "na_ca",
      "EU (London)" => "eu_london",
    }

    aws_id = Provider.find_by_name('aws').id
    @regions = HTTParty.get('http://localhost:3000/instances/locations')
    
    @regions.each do |r|
       create name: name_mapping[r], provider_id: aws_id
    end
  end
end
