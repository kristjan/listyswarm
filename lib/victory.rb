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

  def winners
    return @winners if @winners
    return nil unless done?

    players.each{|player| update_score(player)}
    high_score = players.map(&:score).max
    @winners = players.select{|player| player.score == high_score}
  end

  def world
    @universe.world
  end
end
