class AgentBehavior
  attr_accessor :sensors, :team
  def initialize(team)
    @team = team
  end

  def can_move?(direction)
    !near?(Wall, direction)
  end

  def near?(sprite_class, direction)
    neighbor = Coordinate.neighbor([0, 0], direction)
    sensors.vision(*neighbor).any?{|sprite| sprite.is_a?(sprite_class)}
  end

  def on_spawn_point?
    sensors.vision(0, 0).detect{|sprite| sprite == spawn_point}
  end

  def action
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
