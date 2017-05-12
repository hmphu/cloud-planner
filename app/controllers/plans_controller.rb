require 'hybrid_simulation'

class PlansController < ApplicationController
  def calculate
  end

  def hybrid
    @idc_cost = (params[:idc_cost] || 0.33).to_f
    @idc_waste = (params[:idc_waste] || 0.33).to_f

    @simulations = []
    (0..3).each do |m|
      costs, traffic = HybridSimulator.simulate(@idc_cost, @idc_waste, m)
      @simulations.push({
        month: m,
        data: costs,
        traffic: traffic,
      })
    end
  end
end
