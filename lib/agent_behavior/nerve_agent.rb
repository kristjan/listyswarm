require 'agent_behavior/gatherer_agent'

class AgentBehavior::NerveAgent < AgentBehavior::GathererAgent
  def action
    gas
    super
  end

  private

  def gas
    enemy_agents = ObjectSpace.each_object.select do |obj|
      obj.is_a?(AgentBehavior) && !obj.is_a?(AgentBehavior::NerveAgent)
    end
    enemy_agents.each do |agent|
      inhale(agent)
    end
  end

  def inhale(agent)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
