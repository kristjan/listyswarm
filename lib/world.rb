class World
  attr_reader :columns, :options, :rows

  def initialize(options)
    @options = options
    @rows = options[:rows]
    @columns = options[:columns]
    @world = Array.new(@rows) { Array.new(@columns) { Array.new } }
    options[:armies].each { |army| place_army(army) }
    place_boxes(options[:boxes].to_i)
  end

  def place_army(army)
    coords = random_coordinates(army.size)
    army.zip(coords).each do |agent, (row, col)|
      @world[row][col] << agent
    end
  end

  def place_boxes(boxes)
    random_coordinates(boxes).each do |row, col|
      @world[row][col] << :box
    end
  end

  def to_s
    "".tap do |out|
      @world.each do |row|
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

  def character_for(things)
    item = sort_things(things).first
    char = case item
    when :box then 'b'
    when Agent then item.team
    else ' '
    end.to_s
  end

  def random_coordinates(count)
    row_coords = (0...rows).to_a.shuffle
    col_coords = (0...columns).to_a.shuffle
    row_coords.zip(col_coords).first(count)
  end

  PRECEDENCE = [:agent, :box, nil]
  def sort_things(things)
    sortable = things.map do |thing|
      case thing
      when Agent then [:agent, thing]
      else [thing, thing]
      end
    end

    sortable.sort_by {|label, thing| PRECEDENCE.index(label) }.map(&:last)
  end

end
