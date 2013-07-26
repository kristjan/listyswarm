require 'box'

class World
  attr_reader :options, :boxes, :players, :world
  attr_reader :rows, :columns

  def initialize(options)
    @options = options
    @rows    = options[:rows]
    @columns = options[:columns]
    @players = []
    @world   = build_world
    place_boxes(options[:boxes].to_i)
  end

  def add_player(player)
    @players << player
    place_swarm(player.swarm)
  end

  def to_s
    "".tap do |out|
      @world.each_with_index do |row, i|
        row.each do |things|
          out << character_for(things)
        end
        out << "\n"
      end
    end
  end

  def tick
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

  private

  def build_world
    Array.new(@rows) { Array.new(@columns) { Array.new } }
  end

  def character_for(things)
    item = sort_things(things).first
    char = case item
    when Box then 'b'
    when Agent then item.team
    else ' '
    end.to_s
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
    @world[box.row][box.column] << box
  end

  def place_boxes(count)
    random_coordinates(count).each do |row, col|
      (@boxes ||= []) << Box.new
      place_box(@world, @boxes.last, row, col)
    end
  end

  def random_coordinates(count)
    row_coords = (0...@rows).to_a.shuffle
    col_coords = (0...@columns).to_a.shuffle
    row_coords.zip(col_coords).first(count)
  end

  PRECEDENCE = %w[Agent Box NilClass]
  def sort_things(things)
    things.sort_by do |thing|
      PRECEDENCE.index(thing.class.name.split('::').first)
    end
  end

end
