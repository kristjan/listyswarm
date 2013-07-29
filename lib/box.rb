class Box < Sprite
  attr_accessor :is_held, :owner

  def initialize
    @is_held = false
  end

  def is_held?
    @is_held
  end

  def display_char
    if owner.nil?
      'b'
    else
      ','
    end
  end

  def display_priority
    5
  end

  def owned_by?(representative)
    return false if owner.nil?

    representative_team = representative.team if representative.is_a?(AgentBehavior) || representative.is_a?(Agent)
    owner_team = owner.team

    owner_team == representative_team
  end
end
