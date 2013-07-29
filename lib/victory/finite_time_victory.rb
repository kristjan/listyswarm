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


  # This is an inlined version of longest_chain (stack-backed rather
  # than recursion which incurs the cost of constructing method contexts),
  # but it turns out that it's slower (maybe the duping of the visited sets?)
  def longest_chain2(coord)
    max_chain = 0
    stack = [[1, coord, Set.new]]

    while stack.length > 0
      longest, coord, visited = stack.pop

      visited << coord

      max_chain = longest if max_chain < longest

      to_traverse = []
      Coordinate::DIRECTIONS.each do |dir|
        next_coord = Coordinate.neighbor(coord, dir)
        row, col = next_coord
        if (row < 0 || col < 0 || row >= world.rows || col >= world.columns)
          nil
        elsif visited.include?(next_coord)
          nil
        elsif world[row, col].detect{|item| item.is_a?(Box)}.nil?
          nil
        else
          to_traverse << [longest + 1, next_coord, visited.dup]
        end
      end

      stack += to_traverse
    end

    max_chain
  end

end
