desc "Calc"
task :calc, [:infile] =>  :environment do |t, args|
  #in_file = "#{Rails.root}/calc/#{args[:infile]}"
  in_file = "#{args[:infile]}"
  toml = TOML.load_file(in_file)

  servers = toml['servers']

  total_cost = 0
  monthly_hour = 31*24

  c = {}
  toml['common'].each { |k, v| c[k] = v }

  toml['servers'].each do |name, v|
    c.each { |i,j| v[i] = v[i] || j }

    monthly_hour = Provider.monthly_hours(v['provider'])
    desc, cost = InstanceType.cost(v['provider'], v['region'], v['machine'], v['os'], v)
    if cost
      monthly_cost =  (cost * monthly_hour).to_i
      puts ["%-10s" % name.upcase,
            "$%8.2f" % cost,
            "($%10s/month)" % monthly_cost.to_s(:delimited)
      ].join(' ').blue

      puts desc
      total_cost += cost
    else
      puts desc
    end
  end
  monthly_total =  (total_cost * monthly_hour).to_i
  puts ["%-10s" % 'TOTAL',
        "$%8.2f" % total_cost.round(2),
        "($%10s/month)" % monthly_total.to_s(:delimited)
  ].join(' ').blue
end

desc "info cloud provider"
task :info, [:name] =>  :environment do |t, args|
  puts "Machine Types".blue
  Rake::Task["machines"].invoke(args[:name])
  puts "Regions".blue
  Rake::Task["regions"].invoke(args[:name])
  puts "Softwares".blue
  Rake::Task["software"].invoke(args[:name])
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
