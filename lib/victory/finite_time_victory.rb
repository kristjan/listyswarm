require 'set'

class Victory::FiniteTimeVictory < Victory
  def initialize(players, options={})
    super
    @ticks = 0
    @limit = options[:ticks].to_i
  end

  def done?
    @universe.ticks >= @limit
  end

  def score(player)
    longest_chain(player.spawn_point.location)
  end

  private

  DIRECTIONS = [:north, :south, :east, :west]

  def longest_chain(coord, visited=Set.new)
    row, col = coord
    return 0 if row < 0              ||
                col < 0              ||
                row >= world.rows    ||
                col >= world.columns

    return 0 if visited.include?(coord)
    visited << coord

    return 0 unless world[row, col].detect{|item| item.is_a?(Box)}

    longest = 1 + DIRECTIONS.map do |dir|
      longest_chain(neighbor(coord, dir), visited)
    end.max

    visited.delete coord
    longest
  end

  def neighbor(coord, direction)
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
end
