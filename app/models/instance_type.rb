require 'csv'

class InstanceType < ApplicationRecord
=begin
  enum os_type: [
    :linux, :windows,     :suse,
    :rhel,  :windows_sql, :na,
    :unknown_os
  ]

  enum contract_type: [
    :on_demand,
    :ri_1y_no, :ri_1y_partial, :ri_1y_all,
    :ri_3y_no, :ri_3y_partial, :ri_3y_all,
    :ri_1y, :ri_3y,
    :unknown_contract
  ]

  enum prepay_type: [ :prepay_no, :prepay_partial, :prepay_all ]

  enum unit: [:hourly, :upfront, :unknown_unit]
  enum offering_class: [:standard, :convertible ]

  # :dedicated -> dedicated_instance, :host -> dedicated_host
  enum tenancy_type: [:shared, :dedicated, :host, :unknown_tenancy]
=end

  def self.cost(p, r, m, os, opts = {})
    p, r, m, os = p.downcase, r.downcase, m.downcase, os.downcase
    opts.symbolize_keys!
    opts.transform_values! {|x| x.to_s.downcase }

    software = opts[:software] || 'no sw'
    tenancy = opts[:tenancy] || 'shared'
    price_unit = opts[:price_unit] || 'hourly'
    contract = opts[:contract] || 'on_demand'
    offering = opts[:offering]
    prepay = opts[:prepay]

    count = (opts[:count] || 1).to_i

    if(contract != 'on_demand')
      offering = opts[:offering] || 'standard'
      prepay = opts[:prepay] || 'all'
    end

    if prepay == 'all'
      cost = 0
    else
      params = {
        provider: p,
        region: r,
        machine: m,
        os: os,
        software: software,
        contract: contract,
        tenancy: tenancy,
        price_unit: price_unit,
        offering: offering,
        prepay: prepay,
      }

      ap params if opts[:debug] == 'info'
      instances = InstanceType.where(params) 

      if instances.count > 1
        instances.each {|i| ap i}
        return "ERROR: Too many instance types"
      end

      if instances.count == 0
        return "ERROR: No such instance type"
      end


      inst = instances.first
      cost = inst.price

      ap inst if opts[:debug]
    end


    if ['ri_1y', 'ri_3y'].include?(contract) && opts[:prepay] != 'no'
      params = {
        provider: p,
        region: r,
        machine: m,
        os: os,
        software: software,
        contract: contract,
        prepay: prepay,
        tenancy: tenancy,
        offering: offering,
        price_unit: 'upfront',
      }
      ap params if opts[:debug] == 'info'
      inst2 = InstanceType.where(params).first
      ap inst2 if opts[:debug]

      prepay_cost = inst2.price

      period = 1 if contract == 'ri_1y'
      period = 3 if contract == 'ri_3y'

      prepay_hourly = prepay_cost / (period * 365 * 24)
      cost = cost + prepay_hourly

    end

    unit_cost = cost.round(3)
    cost = cost * count

    desc = [p, r, m, os, software, contract, tenancy, prepay, price_unit, unit_cost.to_s, count.to_s].join(', ')

    return desc, cost.round(3)
  end

  def self.of_type(name)
    where(machine_name: name)
  end

  def self.load_azure_data
    r_list = {}
    m_list = {}
    region, os, sw, offering, contract= nil, nil, nil, nil

    region_names = Region.where(provider_name: 'azure').pluck(:name)
    machine_names = MachineType.where(provider_name: 'azure').pluck(:name)

    filename = "#{Rails.root}/db/raw/azure.csv"
    CSV.foreach( filename) do |row|
      next if row.size < 5
      row.map! {|c| c.downcase if c}

      if row[0]== 'meta'
        # ROW of meta data
        region, os, offering, contract = row[1..4]

        if os == 'sql standard'
          os = 'windows'
          sw = 'sql std'
        else
          sw = 'no sw'
        end

        unless region_names.include? region
          r = p.regions.create(name: region, provider_name: 'azure' )
          region_names.append region
        end
      else
        # ROW of price data
        machine, cores, memory, disk, price = row

        unless machine_names.include? machine
          m = p.machine_types.create(
            name: machine,
            provider_name: 'azure',
            core_count: cores.to_i,
            memory_size: memory.to_f,
            disk_size: disk.to_i,
          )
          machine_names.append machine
        end

        inst = p.instance_types.create(
          region: region,
          machine: machine, 
          os: os,
          price: price.sub(/\$/, '').to_f,
          offering: offering,
          software: sw,
          price_unit: 'hourly',
          contract: 'on_demand',
          tenancy:  'shared',
          prepay: 'no',
        )
#        ap inst #xxx
      end
    end
  end


  def self.load_aws_data
    os_type_map = {
      "windows" => 'windows',
      "linux" => 'linux',
      "rhel" => 'rhel',
      "suse" => 'suse',
      "na" => 'no sw',
    }

    contract_type_map = {
      "1yr no upfront"      => :ri_1y_no,
      "1yr partial upfront" => :ri_1y_partial,
      "1yr all upfront"     => :ri_1y_all,
      "3yr no upfront"      => :ri_3y_no,
      "3yr partial upfront" => :ri_3y_partial,
      "3yr all upfront"     => :ri_3y_all,
      "1yr" => :ri_1y,
      "3yr" => :ri_3y,
    }

    purchase_option_map = {
      "no upfront" => 'no',
      "partial upfront" => 'partial',
      "all upfront" => 'all',
    }

    unit_map = {
      "hrs" => :hourly,
      "quantity" => :upfront,
    }

    tenancy_map = {
      "shared" => :shared,
      "dedicated" => :dedicated,
      "host" => :host,
    }

    machine_names = MachineType.where(provider_name: 'aws').distinct.pluck(:name)

    total_count = 0
    Rgion.where(provider_name: 'aws').each do |region|
      count = 0

      org_name = Region.aws_mapper.find_left(region.name)
      raw_insts = HTTParty.get("http://localhost:3000/instances?location=#{org_name}")

      raw_insts.each do |ri|
        h = {}

        # Ignore BYOL data. Linux price can be used.
        next if ri['license_model'] == "bring your own license"

        # SKIP Unknown machine type
        next unless machine_names.include?(ri['instance_type'])

        h[:provider] = 'aws'
        h[:region] = region.name
        h[:machine] = ri['instance_type']
        h[:os] = os_type_map[ri["operating_system"]].to_s
        h[:contract] = (contract_type_map[ri['lease_contract_length]']] || :on_demand).to_s
        h[:prepay] = purchase_option_map[ri['purchase_option]']].to_s
        h[:price] = ri['price_per_unit']
        h[:price_unit] = unit_map[ri["unit"]].to_s
        h[:tenancy] = tenancy_map[ri["tenancy"]].to_s
        h[:sku] = ri['sku']
        h[:software] = ri['pre_installed_sw']
        h[:offering] = ri['offering_class'].to_s

        new_inst  = region.instance_types.create(h)

        count += 1
        puts "#{region.name} - #{count}......" if count % 1000 == 0
      end

      puts "#{region.name} - #{count} Done."
      total_count += count
      puts "TOTAL - #{total_count}"
    end
  end
end
