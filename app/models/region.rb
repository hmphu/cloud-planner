class NameMapper
  def initialize(mappings)
    #mappings should be a form like [ ['l1', 'r2'], ['l1, 'r2'],...]
    @mappings = mappings
  end

  def find_right(left)
    i = @mappings.index {|m| m.first == left }
    return nil if i.nil?
    return @mappings[i].last
  end

  def find_left(right)
    i = @mappings.index {|m| m.last == right }
    return nil if i.nil?
    return @mappings[i].first
  end
end

class Region < ApplicationRecord
  belongs_to :provider
  has_many :instance_types

  # Global Areas : US, EU, AP(Asia Pacific), 
  #                SA(Aouth America), NA(North America) 
  @@aws_mapper = NameMapper.new ([
      ["US East (Ohio)" , "us_ohio"],
      ["EU (Frankfurt)" , "eu_frankfurt"],
      ["Asia Pacific (Seoul)" , "ap_seoul"],
      ["Asia Pacific (Singapore)" , "ap_singapore"],
      ["Asia Pacific (Sydney)" , "ap_sydney"],
      ["US West (Oregon)" , "us_oregon"],
      ["South America (Sao Paulo)" , "sa_saopaulo"],
      ["US East (N. Virginia)" , "us_virginia"],
      ["US West (N. California)" , "us_california"],
      ["AWS GovCloud (US)" , "us_gov"],
      ["EU (Ireland)" , "eu_ireland"],
      ["Asia Pacific (Tokyo)" , "ap_tokyo"],
      ["Asia Pacific (Mumbai)" , "ap_mumbai"],
      ["Canada (Central)" , "na_ca"],
      ["EU (London)" , "eu_london"],
    ])

  def self.aws_mapper
    @@aws_mapper
  end

  def self.load_aws_regions
    mapper = @@aws_mapper

    aws_id = Provider.find_by_name('aws').id
    @regions = HTTParty.get('http://localhost:3000/instances/locations')
    
    @regions.each do |r|
       create name: mapper.find_right(r), provider_id: aws_id
    end
  end
end
