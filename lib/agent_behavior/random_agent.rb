class AgentBehavior::RandomAgent < AgentBehavior
  def self.avatar
    "mr-t-flex.jpg"
  end

  def action
    [:north, :south, :east, :west, :pickup_box, :drop_box].shuffle.first
  end
end
