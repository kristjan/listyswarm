class SpawnPoint < Sprite
  attr_reader :name
  attr_accessor :player

  def initialize(name, coords)
    @name = name
    @row, @column = coords
  end

  def display_char
    name
  end

  def on_north_edge?
    @row == 0
  end

  def on_south_edge?
    !on_north_edge?
  end

  def on_west_edge?
    @column == 0
  end

  def on_east_edge?
    !on_west_edge?
  end
end
