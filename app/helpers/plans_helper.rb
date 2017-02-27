require 'ap'

module PlansHelper

  def transfrom_cost_data(org)
    data = []

    aws = { name: 'aws',
            data: org.map {|d| [d[0], d[1][:aws]]}}
    idc = { name: 'idc',
            data: org.map {|d| [d[0], d[1][:idc]]}}
    waste = { name: 'waste',
            data: org.map {|d| [d[0], d[1][:waste]]}}

    data.push idc
    data.push waste
    data.push aws

    data
  end

  def transfrom_traffic_data(org)
    tbd =  []
    org.each_with_index do | val, index |
      tbd.push([index, val])
    end

    data = [{ 
      name: 'traffic',
      data: tbd,
    }]

    return data
  end



end
