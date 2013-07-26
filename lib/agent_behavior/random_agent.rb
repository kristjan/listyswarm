class AgentBehavior::RandomAgent < AgentBehavior
  def action
    [:north, :south, :east, :west].shuffle.first
  end
end
