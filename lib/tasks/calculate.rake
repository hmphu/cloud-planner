desc "Calc"
task :calc, [:infile] =>  :environment do |t, args|
  in_file = "#{Rails.root}/calc/#{args[:infile]}"
  toml = TOML.load_file(in_file)

  servers = toml['servers']

  total_cost = 0
  c = {}
  toml['common'].each { |k, v| c[k] = v }

  toml['servers'].each do |k, v|
    name = k

    v['provider']  = v['provider'] || c['provider']
    v['region']    = v['region']     || c['region']
    v['machine']   = v['machine']    || c['machine']
    v['os']        = v['os']         || c['os']

    desc, cost = Provider.cost(v['provider'], v['region'], v['machine'], v['os'], v)

    puts name + ' ----'
    puts cost.to_s  + ' : ' + desc
    total_cost += cost
  end
  puts total_cost.to_s
end

