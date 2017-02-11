desc "Calc"
task :calc, [:infile] =>  :environment do |t, args|
  in_file = "#{Rails.root}/calc/#{args[:infile]}"
  toml = TOML.load_file(in_file)

  servers = toml['servers']

  total_cost = 0
  c = {}
  toml['common'].each { |k, v| c[k] = v }

  toml['servers'].each do |name, v|
    c.each { |i,j| v[i] = v[i] || j }

    desc, cost = InstanceType.cost(v['provider'], v['region'], v['machine'], v['os'], v)

    puts name + ' -- ' + cost.to_s  + ' (' + (cost * 31 * 24).to_s + '/month)'
    puts desc
    total_cost += cost
  end
  puts 'total'+ ' -- ' + total_cost.round(3).to_s + ' (' + (total_cost * 31 * 24).to_s + '/month)'
end

