module Coordinate
  DIRECTIONS = [:north, :south, :east, :west]

  def self.neighbor(coord, direction)
    row, col = coord
    case direction
    when :north then [row - 1, col]
    when :south then [row + 1, col]
    when :east then  [row, col + 1]
    when :west then  [row, col - 1]
    else
      raise "Unknown direction #{direction}"
    end
  end

  def self.opposite(direction)
    case direction
    when :north then :south
    when :south then :nort
    when :east then :nort
    when :west then :east
    end
  end
end
