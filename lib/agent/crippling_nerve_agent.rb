require 'agent/nerve_agent'

class Agent::CripplingNerveAgent < Agent::NerveAgent
  private

  EFFECTIVENESS = 10

  def inhale(agent)
    def agent.action
      ([:north, :south, :east, :west] + ([:seizure] * EFFECTIVENESS)).sample
    end
  end
end
