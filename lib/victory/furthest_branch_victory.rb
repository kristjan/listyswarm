require 'set'
require 'coordinate'

class Victory::FurthestBranchVictory < Victory
  def initialize(players, options={})
    super
    @ticks = 0
    @limit = options[:ticks].to_i
  end

  def done?
    @universe.ticks >= @limit
  end

  def score(player)
    furthest_branch(player.spawn_point.location)
  end

  private

  def furthest_branch(coord, visited=Set.new)
    raise NotImplementedError.new
  end


end
