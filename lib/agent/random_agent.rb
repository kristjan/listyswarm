class Agent::RandomAgent < Agent
  def action
    [:north, :south, :east, :west].shuffle.first
  end
end
