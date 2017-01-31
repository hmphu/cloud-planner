class Provider < ApplicationRecord
  has_many :regions
  has_many :machine_types
  has_many :instance_types



  def self.load_providers
    return "Already Loaded" if self.count > 0

    ['aws', 'azure', 'google'].each do |p|
      create name: p
    end
  end

  def self.cost(p, r, m, os, opts = {})
    provider = Provider.find_by(name: p)
    region = provider.regions.find_by(name: r)
    machine_type = provider.machine_types.find_by(name: m)

    pre_installed_sw  = opts['pre_installed_sw']  || 'na'
    contract_type     = :on_demand
    tenancy           = opts['tenancy']   || :shared
    unit              = opts['unit']      || :hourly
    count             = opts['count']     || 1


    ap opts

    if(['1y', '3y'].include? opts['contract'])
      contract_type = 'ri_' + opts['contract'] + '_' + opts['upfront']
    end

    if(contract_type == :on_demand)
      offering_class = nil
    else
      offering_class    = opts['offering_class'] || :standard
    end

    puts 'xxx contract_type'
    puts contract_type

    if opts['upfront'] == 'all'
      cost = 0
    else
      instances = provider.instance_types.where(
        region_id: region.id,
        machine_type_id: machine_type.id,
        os_type: os.downcase,

        pre_installed_sw: pre_installed_sw,
        contract_type: contract_type,
        tenancy: tenancy,
        unit: unit,
        offering_class: offering_class,
      )

      if instances.count > 1
        instances.each {|i| ap i}
      end


      inst = instances.first
      cost = inst.price
      ap inst
    end


    if ['ri_1y_partial', 'ri_1y_all', 'ri_3y_partial', 'ri_3y_all'].include? contract_type
      inst2 = provider.instance_types.where(
        region_id: region.id,
        machine_type_id: machine_type.id,
        os_type: os.downcase,
        pre_installed_sw: pre_installed_sw,
        contract_type: contract_type,
        tenancy: tenancy,
        offering_class: offering_class,

        unit: :upfront,
      ).first

      ap inst2
      prepay = inst2.price

      period = 1 if ['ri_1y_partial', 'ri_1y_all'].include? contract_type
      period = 3 if ['ri_3y_partial', 'ri_3y_all'].include? contract_type

      upfront_hourly = prepay / (period * 365 * 24)
      cost = cost + upfront_hourly

    end

    cost = cost * count

    desc = [p, r, m, os, pre_installed_sw, contract_type, tenancy, unit, count.to_s].join(', ')

    return desc, cost
  end

end
