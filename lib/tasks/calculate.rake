desc "Calc"
task :calc, [:infile] =>  :environment do |t, args|
  input = TOML.load_file("#{Rails.root}/calc/#{args[:infile]}") 
  servers = input['servers']
  provider = input['common']['provider']
  region = input['common']['region']

  input['servers'].each do |k, v|
    name = k
    machine = v['machine']
    os = v['os']
    region = v['region'] || region

    desc, cost = Provider.cost(provider, region, machine, os, v)

    puts name + ': ' + desc
    puts cost
  end
end

