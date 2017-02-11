class Provider < ApplicationRecord
  has_many :regions
  has_many :machine_types



  def self.load_providers
    return "Already Loaded" if self.count > 0

    ['aws', 'azure', 'google'].each do |p|
      create name: p
    end
  end

  def self.cost(p, r, m, os, opts = {})
    opts.symbolize_keys!
    opts.transform_values! {|x| x.to_s}

    provider = Provider.find_by(name: p)
    region = provider.regions.find_by(name: r)
    machine_type = provider.machine_types.find_by(name: m)

    pre_installed_sw  = opts[:pre_installed_sw]  || 'na'
    tenancy           = opts[:tenancy]   || 'shared'
    unit              = opts[:unit]      || 'hourly'
    count             = (opts[:count]     || 1).to_i
    contract_type     = opts[:contract] || 'on_demand'
    offering_class    = opts[:offering_class] || nil 
    prepay_type       = opts[:prepay_type] || nil

    if(contract_type != 'on_demand')
      offering_class    = opts[:offering_class] || :standard
      prepay_type = 'prepay_' + (opts[:prepay_type] || 'all').to_s
    end

    if opts[:prepay_type] && (opts[:prepay_type].to_sym == :all)
      cost = 0
    else
      instances = provider.instance_types.where(
        region_id: region.id,
        machine_type_id: machine_type.id,
        os_type: os.downcase,

        pre_installed_sw: pre_installed_sw,
        contract_type: contract_type,
        prepay_type: prepay_type,
        tenancy: tenancy,
        unit: unit,
        offering_class: offering_class,
      )

      if instances.count > 1
        instances.each {|i| ap i}
        return "ERROR: Too many instance types"
      end

      if instances.count == 0
        return "ERROR: No such instance type"
      end


      inst = instances.first
      cost = inst.price
    end


    if ['ri_1y', 'ri_3y'].include?(contract_type) && opts[:prepay_type] != 'no'
      inst2 = provider.instance_types.where(
        region_id: region.id,
        machine_type_id: machine_type.id,
        os_type: os.downcase,
        pre_installed_sw: pre_installed_sw,
        contract_type: contract_type,
        prepay_type: prepay_type,
        tenancy: tenancy,
        offering_class: offering_class,
        unit: prepay_type,
      ).first

      prepay = inst2.price

      period = 1 if contract_type == 'ri_1y'
      period = 3 if contract_type == 'ri_3y'

      prepay_hourly = prepay / (period * 365 * 24)
      cost = cost + prepay_hourly

    end

    cost = cost * count

    desc = [p, r, m, os, pre_installed_sw, contract_type, tenancy, unit, count.to_s].join(', ')

    return desc, cost.round(3)
  end

end
