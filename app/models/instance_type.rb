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
    :unknown_contract
  ]

  enum unit: [:hourly, :upfront, :unknown_unit]

  # :dedicated -> dedicated_instance, :host -> dedicated_host
  enum tenancy: [:shared, :dedicated, :host, :unknonw_tenancy]

  def self.of_type(name)
    mid = MachineType.find_by_name(name.to_s).id
    where(machine_type_id: mid)
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
        # BYOL data is ignore. Linux price can be used.
        next if ri['license_model'] == "bring your own license"

        new_inst  = region.instance_types.new

        # machine_type_id
        tmp = machine_types.index {|m| m.name == ri["instance_type"]}
        next if tmp.nil?
        new_inst[:machine_type_id] = machine_types[tmp].id

        # os_type
        tmp = os_type_map[ri["operating_system"]]
        if tmp.nil? and ri['tenancy'] != 'host'
          puts "Unknown os_type: #{ri['operating_system']}" 
          ap ri
        end
        new_inst[:os_type] = tmp or :unknown_os

        # contract_type 
        tmp = :on_demand
        if ["1yr", "3yr"].include? ri["lease_contract_length"]
          tmp = contract_type_map[ ri["lease_contract_length"] + " " + ri["purchase_option"] ]
          if tmp.nil?
            puts "Unknown contract_type: " + ri["lease_contract_length"]+ " " + ri["purchase_option"]
            tmp = :unknown_contract 
          end
        end
        new_inst[:contract_type] = tmp

        # price
        tmp = ri['price_per_unit'] or 0
        new_inst[:price] = tmp

        # unit
        tmp = unit_map[ri["unit"]]
        new_inst[:unit] = tmp or :unknown_unit

        # tenancy
        tmp = tenancy_map[ri["tenancy"]]
        new_inst[:tenancy] = tmp or :unknown_tenancy

        # others
        new_inst[:sku] = ri['sku']
        new_inst[:pre_installed_sw] = ri['pre_installed_sw']

        # create new instance_type
        new_inst[:provider_id] = aws.id
        new_inst.save

        count += 1
        puts "#{region.name} - #{count}......" if count % 1000 == 0
      end

      puts "#{region.name} - #{count} Done."
      total_count += count
      puts "TOTAL - #{total_count}"
    end
  end
end
