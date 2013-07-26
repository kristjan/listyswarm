class Victory
  def initialize(universe, options={})
    @universe = universe
    @options  = options
  end

  def done?
    false
  end

  def players
    @universe.players
  end

  def score(player)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

  def update_score(player)
    player.score = score(player)
  end

  def winner
    return @winner if @winner
    return nil unless done?

    players.each{|player| update_score(player)}
    @winner = players.sort_by(&:score).last
  end

  def world
    @universe.world
  end
end
