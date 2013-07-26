require 'agent/nerve_agent'

class Agent::SubtleNerveAgent < Agent::NerveAgent
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
