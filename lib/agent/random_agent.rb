class Agent::RandomAgent < Agent
  def action(state)
    [:north, :south, :east, :west].shuffle.first
  end
end
