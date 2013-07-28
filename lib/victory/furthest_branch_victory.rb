require 'set'
require 'coordinate'

class Victory::FurthestBranchVictory < Victory
  def initialize(players, options={})
    super
    @limit = options[:ticks].to_i
  end

  def done?
    @universe.ticks >= @limit
  end

  def score(player)
    furthest_branch(player)
  end

  private

  def furthest_branch(player)
    player_boxes = world.boxes.select {|b| b.owner == player }
    return 0 if player_boxes.empty?

    player_boxes.map do |b|
      # use manhattan distance rather than euclidian because
      # chains aren't considered contiguous across a diagnal.
      manhattan_distance(b.row, b.column, player.spawn_point.row, player.spawn_point.column)
    end.max


  end

  def manhattan_distance(row1, col1, row2, col2)
    (row2 - row1).abs + (col2 - col1).abs
  end

end
