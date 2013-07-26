require 'sprite'

class Sprite
  attr_reader :row, :column

  def location
    [@row, @column] if @row && @column
  end

  def location=(coords)
    @row, @column = coords
  end
end
