class SpawnPoint < Sprite
  attr_reader :name

  def initialize(name, coords)
    @name = name
    @row, @column = coords
  end

  def display_char
    name
  end
end
