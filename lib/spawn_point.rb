class SpawnPoint < Sprite
  attr_reader :row, :column, :name

  def initialize(name, coords)
    @name = name
    @row, @column = coords
  end

  def display_char
    name
  end
end
