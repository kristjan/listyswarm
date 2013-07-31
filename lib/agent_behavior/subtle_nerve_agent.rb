require 'agent_behavior/nerve_agent'

class AgentBehavior::SubtleNerveAgent < AgentBehavior::NerveAgent
  private

  def inhale(agent)
    def agent.action
      if sensors.boxes.any?
        [:north, :south, :east, :west].sample
      else
        super
      end
    end
  end
end
