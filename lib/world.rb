class World
  attr_reader :rows, :columns

  SPACES = {
    box: 'b',
    nil => ' '
  }

  def initialize(rows, columns)
    @rows = rows
    @columns = columns
    @world = Array.new(@rows) { Array.new(@columns) }
  end

  def place_boxes(boxes)
    count = 0
    row_coords = (0...rows).to_a.shuffle
    col_coords = (0...columns).to_a.shuffle
    box_coords = row_coords.first(boxes).zip(col_coords.first(boxes))
    box_coords.each do |row, col|
      @world[row][col] = :box
    end
  end

  def to_s
    "".tap do |out|
      @world.each do |row|
        row.each do |space|
          out << SPACES[space]
        end
        out << "\n"
      end
    end
  end

  def tick
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

end
