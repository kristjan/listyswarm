class Box < Sprite
  attr_accessor :is_held, :owner

  def initialize
    @is_held = false
  end

  def is_held?
    @is_held
  end

  def display_char
    'b'
  end

  def display_priority
    5
  end

  def owned_by?(representative)
    representative = representative.player if representative.is_a?(Agent)
    owner == representative
  end
end
