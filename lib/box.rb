class Box < Sprite
  attr_accessor :is_held

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
end
