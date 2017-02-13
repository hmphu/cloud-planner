require 'csv'

class String
  def snake_case
    return downcase if match(/\A[A-Z]+\z/)
      gsub("S/W", "sw").
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z])([A-Z])/, '\1_\2').
      gsub('/', '_').
      gsub(' ', '_').
      downcase
  end
end

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

      instances.each {|i| ap i} if instances.count > 1 && opts[:debug]
      return "ERROR: Too many instance types" if instances.count > 1
      return "ERROR: No such instance type" if instances.count == 0

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
      instances = InstanceType.where(params)

      instances.each {|i| ap i} if instances.count > 1 && opts[:debug]
      return "ERROR: Too many instance types" if instances.count > 1
      return "ERROR: No such instance type" if instances.count == 0

      inst2 = instances.first
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
          r = Region.create(name: region, provider_name: 'azure' )
          region_names.append region
        end
      else
        # ROW of price data
        machine, cores, memory, disk, price = row

        unless machine_names.include? machine
          m = MachineType.create(
            name: machine,
            provider_name: 'azure',
            core_count: cores.to_i,
            memory_size: memory.to_f,
            disk_size: disk.to_i,
          )
          machine_names.append machine
        end

        inst = InstanceType.create(
          provider: 'azure',
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

  def self.load_aws_csv
    cols = [
      [18, "instance_type",],
      [37, "operating_system",],
      [63, "pre_installed_sw",],
      [9, "price_per_unit",],
      [8, "unit",],
      [3, "term_type",],
      [11, "lease_contract_length",],
      [12, "purchase_option",],
      [13, "offering_class",],
      [16, "location",],
      [21, "vcpu",],
      [24, "memory",],
      [25, "storage",],
      [22, "physical_processor",],
      [23, "clock_speed",],
      [35, "tenancy",],
      [38, "license_model",],
      [0, "sku",],
      [14, "product_family",],
    ]

    os_map = {
      "windows" => 'windows',
      "linux" => 'linux',
      "rhel" => 'rhel',
      "suse" => 'suse',
    }

    contract_map = {
      "1yr" => 'ri_1y',
      "3yr" => 'ri_3y',
    }

    prepay_map = { # prepay
      "no upfront" => 'no',
      "partial upfront" => 'partial',
      "all upfront" => 'all',
    }

    price_unit_map = {
      "hrs" => 'hourly',
      "quantity" => 'upfront',
    }

    tenancy_map = {
      "shared" => 'shared',
      "dedicated" => 'dedicated',
      "host" => 'host',
    }

    region_map = {
      "us east (ohio)" => "us_ohio",
      "eu (frankfurt)" => "eu_frankfurt",
      "asia pacific (seoul)" => "ap_seoul",
      "asia pacific (singapore)" => "ap_singapore",
      "asia pacific (sydney)" => "ap_sydney",
      "us west (oregon)" => "us_oregon",
      "south america (sao paulo)" => "sa_saopaulo",
      "us east (n. virginia)" => "us_virginia",
      "us west (n. california)" => "us_california",
      "aws govcloud (us)" => "us_gov",
      "eu (ireland)" => "eu_ireland",
      "asia pacific (tokyo)" => "ap_tokyo",
      "asia pacific (mumbai)" => "ap_mumbai",
      "canada (central)" => "na_ca",
      "eu (london)" => "eu_london",
    }

    load_only_these_regions = [
      'us_ohio',
    ]

    machine_names = MachineType.where(provider_name: 'aws').distinct.pluck(:name)

    count = 0
    filename = "#{Rails.root}/db/raw/ec2.csv"

    CSV.foreach( filename, 
                converters: :numeric, 
                header_converters: lambda {|h| h.snake_case},
                headers: true,
                skip_lines: /^"Format|^"Disclaimer|^"Publication|^"Version|^"OfferCode/) do |row|

      # XXX debug
      #break if count > 20

      h = {}
      cols.each do |i, c|
        row[i].downcase! if row[i].class == String
        h[c] = row[i]
      end


      next unless ['compute instance', 'dedicated host'].include? h["product_family"]
      next if h["instance_type"].nil?
      next if h["price_per_unit"] == 0
      next if h["license_model"] == "bring your own license"
      unless machine_names.include?(h['instance_type'])
        puts "Error: Unknown machine type. " + h['instance_type']
        next
      end

      h2 = {}
      h2[:provider] = 'aws'
      h2[:machine] = h['instance_type']

      h2[:region] = region_map[h["location"]]
      # XXX for debuggging
      next if load_only_these_regions.size > 0 && !load_only_these_regions.include?(h2[:region]) 
      if h2[:region].nil? 
        puts "Error: Unknown region" + h2[:region]
        next
      end

      h2[:os] = os_map[h["operating_system"]]
      h2[:tenancy] = tenancy_map[h["tenancy"]]

      h2[:contract] = contract_map[h['lease_contract_length']] || 'on_demand'
      h2[:prepay] = prepay_map[h['purchase_option']]

      h2[:price_unit] = price_unit_map[h["unit"]]
      h2[:price] = h['price_per_unit']

      h2[:software] = h['pre_installed_sw']
      h2[:software] = 'no sw' if h2[:software].nil? || h2[:software] == 'na'

      h2[:offering] = h['offering_class'] || 'standard'
      h2[:sku] = h['sku']

      inst = InstanceType.create(h2)

      count += 1
      puts "Count: #{count}..." if count % 50 == 0
    end
    puts "Total: #{count}"
  end

end
