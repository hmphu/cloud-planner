require 'hybrid_simulation'

class PlansController < ApplicationController
  def calculate
  end
  def hybrid
    @simul_data = HybridSimulator.simulate(0.33, 0.33, 2, false)
  end
end
