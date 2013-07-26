class VisionCapture
  def initialize(radius)
    @radius = radius
  end

  # @param [World] as in, not just the array
  # @param [Agent]
  def generate_vision(world, agent)
    row, col = [agent.row, agent.column]

    #min_row, max_row = agent.row - @radius, agent.row + @radius
    #min_col, max_col = agent.column - @radius, agent.column + @radius

    vision = Array.new(2 * @radius + 1) { Array.new(2 * @radius + 1) { Array.new } }

    (-@radius..@radius).each do |row_offset|
      (-@radius..@radius).each do |col_offset|

        row = agent.row + row_offset
        column = agent.column + col_offset
        vision[row_offset + @radius][col_offset + @radius] = world.get_sprites(world.world, row, column)
      end
    end

    vision
  end
end
