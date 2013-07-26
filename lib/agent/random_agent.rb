class Agent::RandomAgent < Agent

  def move(state)
    [:north, :south, :east, :west].shuffle.first
  end

end
