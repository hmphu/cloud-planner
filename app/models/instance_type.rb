require 'csv'

class InstanceType < ApplicationRecord
  belongs_to :provider
  belongs_to :region
  belongs_to :machine_type

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
  enum tenancy: [:shared, :dedicated, :host, :unknown_tenancy]

  def self.of_type(name)
    mid = MachineType.find_by_name(name.to_s).id
    where(machine_type_id: mid)
  end

  def self.load_azure_date
    r_list = {}
    m_list = {}

    p = Provider.find(name: 'azure')
    p.regions.each {|r| r_list[r.name] = r.id}
    p.machine_types.each {|m| m_list[m.name] = m.id}

    filename = "#{Rails.root}/db/raw/azure.csv"
    CSV.foreach( filename) do |row| 
      region = nil
      os = nil
      offering = nil
      sw = 'na'

      next if row.size != 5

      row.map! {|c| c.downcase }

      if row[0].downcase == 'meta'
        # ROW of meta data 
        region, os, offering, contract_type = row[1..4]

        if os == 'sql standard'
          os = 'windows'
          sw = 'sql std'
        else
          sw = 'na'
        end


        unless r_list[region]
          r = p.regions.create(name: region)
          r_list[region] = r.id
        end
      else
        # ROW of price data
        machine, cores, memory, disk, price = row 

        unless m_list[machine]
          m = p.machine_types.create(
            name: machine,
            core_count: cores.to_i,
            memory_size: momory.to_f,
            disk_size: disk.to_i,
          )
          m_list[machine] = m.id
        end

        p.instance_types.create(
          region_id: r_list[region],
          machine_type_id: m_list[machine],
          os_type: os,
          price: price.sub(/\$/, '').to_f,
          offering_class: offering,
          pre_installed_sw: sw 
          unit: 'hr',
          contract_type: xx,
          tenancy:  'shared',
          prepay_type: xx,
        )

      end
    end


  end


  def self.load_aws_data
    os_type_map = {
      "windows" => :windows,
      "linux" => :linux,
      "rhel" => :rhel,
      "suse" => :suse,
      "na" => :na,
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
      "no upfront" => :prepay_no,
      "partial upfront" => :prepay_partial,
      "all upfront" => :prepay_all,
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


    aws = Provider.find_by_name('aws')
    machine_types = aws.machine_types.all.to_a

    total_count = 0
    aws.regions.each do |region|
      count = 0

      org_name = Region.aws_mapper.find_left(region.name)
      raw_insts = HTTParty.get("http://localhost:3000/instances?location=#{org_name}")

      raw_insts.each do |ri|
        h = {}

        # BYOL data is ignore. Linux price can be used.
        next if ri['license_model'] == "bring your own license"

        # machine_type_id
        tmp = machine_types.index {|m| m.name == ri["instance_type"]}
        next if tmp.nil?
        h[:machine_type_id] = machine_types[tmp].id

        # os_type
        h[:os_type] = os_type_map[ri["operating_system"]]

        h[:contract_type] = contract_type_map[ri['lease_contract_length]']] || :on_demand
        h[:prepay_type] = purchase_option_map[ri['purchase_option]']]

        h[:price] = ri['price_per_unit']
        h[:unit] = unit_map[ri["unit"]]
        h[:tenancy] = tenancy_map[ri["tenancy"]]
        h[:sku] = ri['sku']
        h[:pre_installed_sw] = ri['pre_installed_sw']
        h[:offering_class] = ri['offering_class']
        h[:provider_id] = aws.id

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
