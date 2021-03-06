class Sensors
  attr_accessor :vision_array, :vision_radius, :has_box,
    :foe_teams, :friendly_spawn_dir, :foe_spawn_dirs, :spawn_point,
    :agent_id, :swarm_size, :debug_world, :debug_agent

  # Generates the hash that is given to the behavior function
  def self.create(world, agent)
    @vision_capture ||= VisionCapture.new(world.options[:vision_radius])

    # any data that, for the purposes of fairness, needs to be cleaned or
    # precomputed should be passed in the init.  the rest should just
    sensors = Sensors.new(world, {
      :vision_radius => world.options[:vision_radius],
      :vision_array => @vision_capture.generate_vision(world, agent),
      :has_box => agent.has_box?,
      :foe_teams => world.players.select{|p| p != agent.player}.map(&:team),
      :friendly_spawn_dir => direction_of(agent, agent.spawn_point),
      :foe_spawn_dirs => foe_spawn_dirs(agent, world.players),
      :agent_id => agent.id,
      :swarm_size => world.options[:swarm_size],
      #deprecated: don't use spawn point
      :spawn_point => agent.spawn_point
    })

    # if in debug mode, give full access to world and agent
    if world.options[:debug_mode]
      sensors.debug_world = world
      sensors.debug_agent = agent
    end

    sensors
  end

  def initialize(world, options)
    options.each_pair {|key, value| self.send("#{key}=", value) }
  end

  def self.foe_spawn_dirs(agent, players)
    dirs = {}

    players.select{|p| p != agent.player}.each do |p|
      dirs[p.team] = direction_of(agent, p.spawn_point)
    end

    dirs
  end

  # returns an ordered pair of magnitudes, normalized such that their
  # distance is equal to 1 (like a unit circle in geometry)
  def self.direction_of(agent, target)
    start_row, start_col = agent.row, agent.column
    end_row, end_col = target.row, target.column

    #use pythagorans to get the distance
    row_diff = end_row - start_row
    col_diff = end_col - start_col
    dist = Math.sqrt(row_diff ** 2.0 + col_diff ** 2.0)
    return [0,0] if dist == 0

    #normalize to get a unit vector (directional vector of length 1)
    [row_diff / dist, col_diff / dist]
  end

  def boxes
    [].tap do |visible_boxes|
      vision_array.each_with_index do |row, row_num|
        row.each_with_index do |sprites, column_num|
          if sprites.detect{|sprite| sprite.is_a?(Box)}
            visible_boxes << [row_num - row_radius, column_num - column_radius]
          end
        end
      end
    end
  end

  def enemies
    [].tap do |visible_enemies|
      vision_array.each_with_index do |row, row_num|
        row.each_with_index do |sprites, column_num|
          if sprites.detect do |sprite|
            sprite.is_a?(Agent) && foe_teams.include?(sprite.team)
          end
            visible_enemies << [row_num - row_radius, column_num - column_radius]
          end
        end
      end
    end
  end

  # the offsets should be <= the vision radius.
  # returns the sprites at the position offset to the agent
  # a [0,0] offset would return the sprites on the agents square
  def vision(row_offset, column_offset)
    vision_array[row_radius + row_offset][column_radius + column_offset]
  end

  def each_visible
    vision_array.each_with_index do |row, row_num|
      row.each_with_index do |sprites, col_num|
        yield sprites, row_num, col_num
      end
    end
  end

  def have_box?
    self.has_box
  end

  def row_radius
    (vision_array.length / 2.0).floor
  end

  def column_radius
    (vision_array.first.length / 2.0).floor
  end

  def vision_to_s
    "---Vision\n" + World.world_to_s(vision_array)
  end
end
