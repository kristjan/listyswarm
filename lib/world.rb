require 'box'

class World
  attr_reader :columns, :options, :rows, :world

  def initialize(options)
    @options = options
    @rows = options[:rows]
    @columns = options[:columns]
    @world = build_world
    @swarms = options[:swarms]
    @swarms.each { |swarm| place_swarm(swarm) }
    @vision_capture = VisionCapture.new(options[:vision_radius])
    place_boxes(options[:boxes].to_i)
  end

  def place_swarm(swarm)
    coords = random_coordinates(swarm.size)
    swarm.zip(coords).each do |agent, (row, col)|
      @world[row][col] << agent
      agent.location = [row, col]
    end
  end

  def place_box(world, box, row, column)
    box.location = [row, column]
    world[box.row][box.column] << box
  end

  def place_boxes(boxes)
    random_coordinates(boxes).each do |row, col|
      (@boxes ||= []) << Box.new
      place_box(@world, @boxes.last, row, col)
    end
  end

  def to_s
    self.class.world_to_s(@world)
  end

  def self.world_to_s(world)
    "".tap do |out|
      world.each_with_index do |row, i|
        row.each do |things|
          out << character_for(things)
        end
        out << "\n"
      end
    end
  end

  # returns the sprites at the row and column.  if the row and column are
  # outside the range of the world, return a wall.
  def get_sprites(world_arr, row, col)
    if row < 0 || col < 0 || row >= @rows || col >= @columns
      Array.new([Wall.new])
    else
      world[row][col]
    end
  end

  def tick
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

  private

  def build_world
    make_grid(@rows, @columns)
  end

  def make_grid(row_count, column_count)
    Array.new(row_count) { Array.new(column_count) { Array.new } }
  end

  def self.character_for(things)
    item = sort_things(things).first
    char = case item
    when Box then 'b'
    when Agent then item.team
    else ' '
    end.to_s
  end

  def random_coordinates(count)
    row_coords = (0...rows).to_a.shuffle
    col_coords = (0...columns).to_a.shuffle
    row_coords.zip(col_coords).first(count)
  end

  PRECEDENCE = %w[Agent Box NilClass]
  def self.sort_things(things)
    things.sort_by do |thing|
      PRECEDENCE.index(thing.class.name.split('::').first)
    end
  end

end
