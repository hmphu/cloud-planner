require 'hybrid_simulation'

class HybridSimulationController < ApplicationController
  def new
  end

  def result
    @idc_cost = (params[:idc_cost] || 0.33).to_f
    @idc_waste = (params[:idc_waste] || 0.33).to_f

    @simulations = []
    [[6,'대박'], [2, '중박'], [0, '쪽박']].each do |growth_months, game_type|
      costs, traffic = HybridSimulator.simulate(@idc_cost, @idc_waste, growth_months)
      @simulations.push({
        month: growth_months,
        data: costs,
        traffic: traffic,
        game_type: game_type,
      })
    end
  end
end
