class Sensors
  attr_accessor :vision_array, :vision_radius, :has_box, :foe_teams

  # Generates the hash that is given to the behavior function
  def self.create(world, agent)
    @vision_capture ||= VisionCapture.new(world.options[:vision_radius])

    #TODO: include direction towards home spawn and (maybe) other teams spawns
    Sensors.new({
      :vision_radius => world.options[:vision_radius],
      :vision_array => @vision_capture.generate_vision(world, agent),
      :has_box => agent.has_box?,
      :foe_teams => world.players.map(&:team),
    })
  end

  def initialize(options)
    options.each_pair {|key, value| self.send("#{key}=", value) }
  end

  # the offsets should be <= the vision radius.
  # returns the sprites at the position offset to the agent
  # a [0,0] offset would return the sprites on the agents square
  def vision(row_offset, column_offset)
    # these numbers will always be odd
    rows = vision_array.length
    columns = vision_array.first.length

    # these will probably be the same, but maybe not later
    rows_radius = (rows / 2.0).floor
    columns_radius = (columns / 2.0).floor

    vision_array[rows_radius + row_offset][columns_radius + column_offset]
  end

  def have_box?
    self.has_box
  end

  def put_vision
    puts "---Vision\n" + World.world_to_s(vision_array)
  end
end
