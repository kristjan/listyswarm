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
    # TODO: Count longest path
    rand(10)
  end
end
