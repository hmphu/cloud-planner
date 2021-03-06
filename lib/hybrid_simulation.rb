# hybrid cloud - cost simulation


# there are  4 phases of life cycle
# phase 1: fast growing 
# phase 2: fast decreasing 
# phase 3: slow decreasing 
# phase 4: stable 


# length of phase 1 (months)
# if a game traffic goes down,  p0 = 0 
#
module HybridSimulator

  def self.make_phases(p1_length = 2)
    p1_g = 1.225
    p2_g = 0.691
    p3_g = 0.906
    p4_g = 1.0
    p1_l = 2
    p2_l = 3
    p3_l = 7
    p4_l = 12

    p1_l = p1_length

    phases = [
      [p1_g, p1_l],
      [p2_g, p2_l],
      [p3_g, p3_l],
      [p4_g, p4_l],
    ]
  end

  def self.make_traffic(phases)
    traffic = []
    month = 0

    traffic[month] = 100

    phases.each do | growth, length|
      length.times do 
        traffic[month + 1] = traffic[month] * growth
        month = month + 1
      end
    end

    return traffic
  end


  def self.cost_bar(aws, idc, waste)
    aws = aws.to_i
    idc = idc.to_i
    waste = waste.to_i

    aws = aws == 0 ? 0 : aws / 2
    idc = idc == 0 ? 0 : idc / 2
    waste = waste == 0 ? 0 : waste / 2

    'i'*idc + 'w' * waste + 'a'*aws
  end

  # idc_capacity_rate : rate of prepared idc capacity compared to the max traffic 
  # show_graph : print visual bar chart
  def self.hybrid_cost(traffic, idc_capacity_rate, idc_cost_ratio, idc_waste_ratio, show_graph, monthly_result=false)
    puts "\nIDC Rate: #{idc_capacity_rate*100}%" if show_graph

    idc_cost, aws_cost, waste_cost  = 0, 0, 0
    idc_costs, aws_costs, waste_costs = [], [], []

    # Assume that idc_capacity is provied as some rate of the maximum traffic over given months  
    idc_capacity = traffic.max * idc_capacity_rate

    before_peak = true

    traffic.each do |t|
      before_peak = false if t == traffic.max

      # t_aws: traffic portion to be covered by AWS
      # t_idc: traffic portion to be covered by IDC  
      # t_waste: IDC capacity - traffic (or 0 if traffic < IDC capacity) 
      t_aws = t > idc_capacity ? t - idc_capacity : 0

      if before_peak
        t_idc = idc_capacity
        t_waste = 0
      else
        t_idc = t < idc_capacity ? t : idc_capacity
        t_waste = t < idc_capacity ? idc_capacity - t : 0
      end

      a = t_aws
      i = t_idc * idc_cost_ratio
      w = t_waste * idc_cost_ratio * idc_waste_ratio

      if show_graph
        puts '*'* (t/2)
        puts cost_bar(a, i, w)
      end

      aws_cost = aws_cost + a 
      idc_cost = idc_cost + i
      waste_cost = waste_cost + w

      aws_costs.push  a 
      idc_costs.push  i
      waste_costs.push w
    end

    if monthly_result
      return aws_costs, idc_costs, waste_costs
    else
      return aws_cost, idc_cost, waste_cost
    end
  end



  # idc_cost_ratio  : idc cost is lower than the cost of aws. idc unit cost / aws unit cost
  # idc_waste_ratio : it is not possible to reuse a server as soon as we get an available server 
  # pahse1_length   : length of traffic increaing phase after the launcing (months)
  def self.simulate(idc_cost_ratio, idc_waste_ratio, phase1_length, show_graph = false)
    phases = make_phases(phase1_length)
    traffic = make_traffic(phases)

    costs = []

    (0..200).step(10) do |rate|
      aws, idc, waste  =  hybrid_cost(traffic, rate/100.0, idc_cost_ratio, idc_waste_ratio, show_graph)
      costs.push([[rate.to_s+"%"], {aws: aws, idc: idc, waste: waste}])
    end

    return costs, traffic
  end

  def self.simulate_details(idc_cost_ratio, idc_waste_ratio, phase1_length)
    phases = make_phases(phase1_length)
    traffic = make_traffic(phases)

    costs = []

    (0..200).step(10) do |rate|
      aws, idc, waste  =  hybrid_cost(traffic, rate/100.0, idc_cost_ratio, idc_waste_ratio, show_graph = false, monthly_result = true)
      costs.push([rate.to_s, {aws: aws, idc: idc, waste: waste}])
    end

    return costs, traffic
  end
end


#data = HybridSimulator.simulate(0.33, 0.33, 2, false)




