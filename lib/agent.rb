require 'sprite'

class Agent < Sprite
  attr_reader :team

  def initialize(team)
    @team = team
  end

  def action(state)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
