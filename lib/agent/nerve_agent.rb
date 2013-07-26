class Agent::NerveAgent < Agent::GathererAgent
  def action
    gas
    super
  end

  private

  def gas
    enemy_agents = ObjectSpace.each_object.select do |obj|
      obj.is_a?(Agent) && obj.player != self.player
    end
    enemy_agents.each do |agent|
      inhale(agent)
    end
  end

  def inhale(agent)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
