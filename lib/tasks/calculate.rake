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
    if cost
      puts "#{name.upcase}\t$#{cost.to_s}($#{(cost * 31 * 24).to_i}/month)"
      puts desc+"\n\n"
      total_cost += cost
    else
      puts desc
    end
  end
  puts "TOTAL\t$#{total_cost.round(3).to_s}($#{(total_cost * 31 * 24).to_i}/month)"
end

desc "regions"
task :regions, [:name] =>  :environment do |t, args|
  list = InstanceType.where(provider: args[:name]).distinct.pluck(:region)
  list.sort.each {|i| puts "#{args[:name].ljust(10)} #{i}"}
end

desc "machines"
task :machines, [:name] =>  :environment do |t, args|
  list = MachineType.where(provider_name: args[:name]).all
  l2 = list.sort {|x, y| x.name <=> y.name}
  l2.each {|i| puts i.desc }
end
