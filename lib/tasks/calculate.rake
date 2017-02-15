desc "Calc"
task :calc, [:infile] =>  :environment do |t, args|
  #in_file = "#{Rails.root}/calc/#{args[:infile]}"
  in_file = "#{args[:infile]}"
  toml = TOML.load_file(in_file)

  servers = toml['servers']

  total_cost = 0
  c = {}
  toml['common'].each { |k, v| c[k] = v }

  toml['servers'].each do |name, v|
    c.each { |i,j| v[i] = v[i] || j }

    desc, cost = InstanceType.cost(v['provider'], v['region'], v['machine'], v['os'], v)
    if cost
      puts "#{name.upcase}\t$#{cost.to_s} ($#{(cost * 31 * 24).to_i.to_s(:delimited)}/month)".blue
      puts desc+"\n"
      total_cost += cost
    else
      puts desc
    end
  end
  puts "TOTAL\t$#{total_cost.round(3).to_s(:delimited)} ($#{(total_cost * 31 * 24).to_i.to_s(:delimited)}/month)\n".blue
end

desc "list of regions"
task :regions, [:name] =>  :environment do |t, args|
  list = InstanceType.where(provider: args[:name]).distinct.pluck(:region)
  list.sort.each {|i| puts "#{args[:name].ljust(10)} #{i}"}
end

desc "list of machines"
task :machines, [:name] =>  :environment do |t, args|
  list = MachineType.where(provider_name: args[:name]).all
  l2 = list.sort {|x, y| x.name <=> y.name}
  l2.each {|i| puts i.desc }
end

desc "lookup matching instances"
task :lookup, [:cores, :memory, :provider] => :environment do |t, args|
  list = MachineType.lookup(args[:cores], args[:memory], args[:provider])
  list.each { |i| puts i.desc }
end

desc "list of softwares"
task :software, [:name] =>  :environment do |t, args|
  list = InstanceType.where(provider: args[:name]).distinct.pluck(:software)
  list.each {|i| puts "#{args[:name].ljust(10)} #{i.to_s}"}
end
