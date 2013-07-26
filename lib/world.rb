require 'box'

class World
  attr_reader :columns, :options, :rows

  def initialize(options)
    @options = options
    @rows = options[:rows]
    @columns = options[:columns]
    @world = build_world
    @armies = options[:armies]
    @armies.each { |army| place_army(army) }
    place_boxes(options[:boxes].to_i)
  end

  def place_army(army)
    coords = random_coordinates(army.size)
    army.zip(coords).each do |agent, (row, col)|
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

  def random_coordinates(count)
    row_coords = (0...rows).to_a.shuffle
    col_coords = (0...columns).to_a.shuffle
    row_coords.zip(col_coords).first(count)
  end

  PRECEDENCE = %w[Agent Box NilClass]
  def sort_things(things)
    things.sort_by do |thing|
      PRECEDENCE.index(thing.class.name.split('::').first)
    end
  end

end
