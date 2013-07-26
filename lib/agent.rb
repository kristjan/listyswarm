require 'sprite'

class Agent < Sprite
  attr_reader :player, :id

  def initialize(player, id)
    @player = player
    @id = id
  end

  def action(state)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

  def team
    player.team
  end
end
