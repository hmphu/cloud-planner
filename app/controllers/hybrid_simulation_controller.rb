require 'hybrid_simulation'

class HybridSimulationController < ApplicationController
  def new
  end

  def result
    @idc_cost = (params[:idc_cost] || 0.33).to_f
    @idc_waste = (params[:idc_waste] || 0.33).to_f

    @simulations = []
    [[6,'대박'], [2, '중박'], [0, '쪽박']].each do |phase1_length, game_type|
      costs, traffic = HybridSimulator.simulate(@idc_cost, @idc_waste, phase1_length)
      @simulations.push({
        month: phase1_length,
        data: costs,
        traffic: traffic,
        game_type: game_type,
      })
    end
  end

  def details
    @idc_cost = (params[:idc_cost] || 0.33).to_f
    @idc_waste = (params[:idc_waste] || 0.33).to_f
    @phase1_length = (params[:phase1_length] || 3).to_i

    @costs, @traffic = HybridSimulator.simulate_details(@idc_cost, @idc_waste, @phase1_length )

    @max = @traffic.max 
    @max = (@max / 100.0 * 2 + 0.5).round * 100 / 2
  end
end
