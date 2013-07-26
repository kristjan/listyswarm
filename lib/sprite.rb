require 'sprite'

class Sprite
  attr_reader :row, :column

  def location=(coords)
    @row, @column = coords
  end
end
