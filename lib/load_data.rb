def load_proivders
  providers = ['aws', 'azure', 'google']

  providers.each do |p|
    Provider.create name: p
  end
end

def load_regions
  #aws
  provider_regions = [
    { 
      name: 'aws',  
      regions: ['kr_seoul'] 
    },
    {
      name: 'azure',  
      regions: ['kr_center', 'kr_south']
    },
    {
      name: 'google',
      regions: []
    }
  ]


  provider_regions.each do |pr|
    p = Provider.find_by_name(pr[:name])
    pr[:regions].each do |r|
      p.regions.create name: r
    end
  end
end

def load_machine_types
end
