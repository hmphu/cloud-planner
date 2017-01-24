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
      ["us east (ohio)" , "us_ohio"],
      ["eu (frankfurt)" , "eu_frankfurt"],
      ["asia pacific (seoul)" , "ap_seoul"],
      ["asia pacific (singapore)" , "ap_singapore"],
      ["asia pacific (sydney)" , "ap_sydney"],
      ["us west (oregon)" , "us_oregon"],
      ["south america (sao paulo)" , "sa_saopaulo"],
      ["us east (n. virginia)" , "us_virginia"],
      ["us west (n. california)" , "us_california"],
      ["aws govcloud (us)" , "us_gov"],
      ["eu (ireland)" , "eu_ireland"],
      ["asia pacific (tokyo)" , "ap_tokyo"],
      ["asia pacific (mumbai)" , "ap_mumbai"],
      ["canada (central)" , "na_ca"],
      ["eu (london)" , "eu_london"],
    ])

  def self.aws_mapper
    @@aws_mapper
  end

  def self.load_aws_regions
    mapper = @@aws_mapper
    aws = Provider.find_by_name('aws').id
    aws.regions.delete_all
    @regions = HTTParty.get('http://localhost:3000/instances/locations')
    @regions.each do |r|
       create name: mapper.find_right(r), provider_id: aws.id
    end
  end
end
