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

  # the offsets should be <= the vision radius.
  # returns the sprites at the position offset to the agent
  # a [0,0] offset would return the sprites on the agents square
  def vision(row_offset, column_offset)
    vision_array[row_radius + row_offset][column_radius + column_offset]
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

  def put_vision
    puts "---Vision\n" + World.world_to_s(vision_array)
  end
end
