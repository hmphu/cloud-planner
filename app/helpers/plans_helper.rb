require 'ap'

module PlansHelper

  def networth_data
    [
      {name: "traffic", data: {"t1": 10532.32, "c1": 0,  "t2": 8900}},
      {name: "aws", data: {"c1": 6979.53, "c2": 4500}}, 
      {name: "idc", data: {"c1": 6979.53, "c2": 4500}}, 
    ]
  end

  def transfrom_to_chart_data(org)
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



end
