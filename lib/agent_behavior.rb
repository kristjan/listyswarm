class AgentBehavior
  attr_accessor :sensors, :team

  # only output debug information when the behavior function is
  # being applied to the agent with this ID.  We choose 0 as the id
  # because it is guarenteed to exist
  DEBUGGING_AGENT_ID = 0

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

  # Given a 2-d vector of a coordinate offset, return
  # the behavior direction that would get you closer to that.
  #
  # @param rand [TrueClass, FalseClass] If true and the offset has
  # both a non-zero row and a non-zero column component, will randomly
  # choose between closing the gap on the row dimension or the column
  # dimension.  The probability is weighted by the magnitive of the
  # offset in that dimension.  If false, will favor fixing the row offset
  # component first.
  def towards_coords_offset(coords_offset, rand = true)
    row, col = coords # Relative

    if rand
      total = coords_offset[0] + coords_offset[1]

    else
      return case
        when row < 0 then :north
        when row > 0 then :south
        when col < 0 then :west
        when col > 0 then :east
      end
    end
  end

  # Odds should be in the form of [[weight1, lamba1], [weight2, lamba2], ...]
  def weighted_randomizer(odds)
    total = odds.map {|odd| odd[0]}.reduce(:+).to_f

    rand = Universe::RNG.rand(1.0)
    cumulative = 0
    chosen = odds.find do |odd|
      cumulative += odd[0] / total
      rand < cumulative
    end

    chosen[1].call
  end

  # Note that showing debug info inside the behavior function would flood
  # us with output.  Instead, we limit the outputted debug to only
  # showing debug output for agent #1
  def add_debug(str)
    if sensors.agent_id == DEBUGGING_AGENT_ID
      @debug_str << str
    end
  end
end
