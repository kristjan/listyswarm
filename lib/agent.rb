require 'sprite'

class Agent < Sprite
  attr_reader :id, :player
  attr_accessor :box, :sensors

  def initialize(player, id)
    @player = player
    @id = id
  end

  def can_move?(direction)
    !near?(Wall, direction)
  end

  def near?(sprite_class, direction)
    neighbor = Coordinate.neighbor([0, 0], direction)
    sensors.vision(*neighbor).any?{|sprite| sprite.is_a?(sprite_class)}
  end

  def has_box?
    !@box.nil?
  end

  def display_char
    if has_box?
      team.upcase
    else
      team
    end
  end

  def display_priority
    has_box? ? 11 : 10
  end

  def action
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

  def spawn_point
    player.spawn_point
  end

  def on_spawn_point?
    sensors.vision(0, 0).detect{|sprite| sprite == spawn_point}
  end

  def team
    player.team
  end
end
