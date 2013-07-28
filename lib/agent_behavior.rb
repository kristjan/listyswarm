class AgentBehavior
  attr_accessor :sensors, :team

  # only output debug information when the behavior function is
  # being applied to the agent with this ID
  DEBUGGING_AGENT_ID = 1

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

  # The player should implement this in a subclass
  def action
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

  def perform_action
    @debug_str = ''

    result = action

    if sensors.agent_id == DEBUGGING_AGENT_ID
      Universe.debug_str << "\nDEBUG for team #{team} and id #{DEBUGGING_AGENT_ID}\n#{@debug_str}"
    end

    result
  end


  # Note that showing debug info inside the behavior function would flood
  # us with output.  Instead, we limit the outputted debug to only being
  # Default to showing debug output for agent #1
  def add_debug(str)
    if sensors.agent_id == DEBUGGING_AGENT_ID
      @debug_str << str
    end
  end
end
