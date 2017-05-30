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

  def transfrom_cost_detail_data(org )
    data = []

    aws = { name: 'aws', data: org[:aws].each_with_index.map {|x, i| [i, x]}}
    idc = { name: 'idc', data: org[:idc].each_with_index.map {|x, i| [i, x]}}
    waste = { name: 'waste', data: org[:waste].each_with_index.map {|x, i| [i, x]}}

    data.push idc
    data.push waste
    data.push aws

    data
  end
  def total_of_monthly (org)
    sum = 0
    sum = sum + org[:aws].sum
    sum = sum + org[:idc].sum
    sum = sum + org[:waste].sum
    sum.to_i
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

  def find_min_cost(org)
    min = org.min {|a, b| a[1][:aws] + a[1][:idc] + a[1][:waste] <=> b[1][:aws] + b[1][:idc] + b[1][:waste] }

    min
  end

  def rate_vs_allin(org)
    min = find_min_cost(org)
    allin= org[0]

    min_cost = min[1][:aws] + min[1][:idc] + min[1][:waste]
    allin_cost = allin[1][:aws] + allin[1][:idc] + allin[1][:waste]

   (min_cost * 100 / allin_cost).to_i
  end




end
