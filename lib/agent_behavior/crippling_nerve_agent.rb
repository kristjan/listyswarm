require 'agent_behavior/nerve_agent'

class AgentBehavior::CripplingNerveAgent < AgentBehavior::NerveAgent
  private

  EFFECTIVENESS = 10

  def inhale(agent)
    def agent.action
      ([:north, :south, :east, :west] + ([:seizure] * EFFECTIVENESS)).sample
    end
  end
end
