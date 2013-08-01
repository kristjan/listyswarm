class AgentBehavior
  attr_accessor :sensors, :team

  # only output debug information when the behavior function is
  # being applied to the agent with this ID.  We choose 0 as the id
  # because it is guarenteed to exist
  DEBUGGING_AGENT_ID = 0

  def initialize(team)
    @team = team
  end

  # example:
  # local: 'myavatar.png'
  # remote: 'http://www.example.com/myavatar.png'
  def self.avatar
  end

  def can_move?(direction)
    !near?(Wall, direction)
  end

  def near?(sprite_class, direction)
    neighbor = Coordinate.neighbor([0, 0], direction)
    sensors.vision(*neighbor).any?{|sprite| sprite.is_a?(sprite_class)}
  end

  def on_spawn_point?
    sensors.vision(0, 0).detect{|sprite| sprite.is_a?(SpawnPoint) && sprite.player.team}
  end

  def on_box?
    sensors.vision(0, 0).select(&:box?).any? do |box|
      !box.owned_by?(self)
    end
  end

  def near_box_chain?
    towards_spawn_point.detect do |direction|
      coords = Coordinate.neighbor([0, 0], direction)
      sensors.vision(*coords).select(&:box?).any? do |box|
        box.owned_by?(self)
      end
    end
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
  def towards_coords_offset(coords_offset, seed=nil)
    return nil if coords_offset == [0,0]
    row, col = coords_offset # Relative

    if seed.nil?
      horiz_weight = coords_offset[0]
      vert_weight = coords_offset[1]

      dir = nil
      weighted_randomizer([
        [horiz_weight, -> { dir = coords_offset[0] < 0 ? :north : :south }],
        [vert_weight, -> { dir = coords_offset[1] < 0 ? :west : :east }],
      ])

      return dir
    else

      # use the seed to determine what we are doing
      cutoff = ((seed % 1000) + 1) / 1000.0 # ranges [0, 1.0]
      ratio = row.to_f / (row.to_f + col.to_f) # ranges [0, 1.0]

      if ratio > cutoff
        return :north if row < 0
        return :south if row > 0
      else
        return :west if col < 0
        return :east if col > 0
      end
    end
  end

  # Odds should be in the form of [[weight1, lamba1], [weight2, lamba2], ...]
  def weighted_randomizer(odds)
    total = odds.map {|odd| odd[0].abs}.reduce(:+).to_f

    rand = Universe::RNG.rand(1.0)
    cumulative = 0
    chosen = odds.find do |odd|
      cumulative += odd[0].abs / total
      rand < cumulative
    end

    require 'pry'
    binding.pry if chosen.nil?

    chosen[1].call
  end

  # Note that showing debug info inside the behavior function would flood
  # us with output.  Instead, we limit the outputted debug to only
  # showing debug output for agent #1
  def add_debug(str)
    @debug_str ||= ''
    if sensors.agent_id == DEBUGGING_AGENT_ID
      @debug_str << str
    end
  end

  def have_box?
    sensors.have_box?
  end
end
