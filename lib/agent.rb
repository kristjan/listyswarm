class Agent
  attr_reader :team

  def initialize(team)
    @team = team
  end

  def move(state)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
