require 'set'

require 'coordinate'

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

  def longest_chain(coord, visited=Set.new)
    row, col = coord
    return 0 if row < 0              ||
                col < 0              ||
                row >= world.rows    ||
                col >= world.columns

    return 0 if visited.include?(coord)
    visited << coord

    return 0 unless world[row, col].detect{|item| item.is_a?(Box)}

    longest = 1 + Coordinate::DIRECTIONS.map do |dir|
      longest_chain(Coordinate.neighbor(coord, dir), visited)
    end.max

    visited.delete coord
    longest
  end

end
