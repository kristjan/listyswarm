class AgentBehavior::RandomAgent < AgentBehavior
  def action
    [:north, :south, :east, :west, :pickup_box, :drop_box].shuffle.first
  end
end
