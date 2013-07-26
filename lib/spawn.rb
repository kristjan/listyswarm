class Spawn
  def initialize(options={})
    @options = options
  end

  def spawn(world, player)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
