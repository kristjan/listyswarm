require 'sprite'

class Agent < Sprite
  attr_reader :id, :team

  def initialize(team, id)
    @team = team
    @id = id
  end

  def action(state)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
