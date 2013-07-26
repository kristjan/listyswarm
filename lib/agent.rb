class Agent
  def move(state)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
