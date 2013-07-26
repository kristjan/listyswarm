class World::SynchronizedWorld < World
  def tick
    new_world = build_world

    @boxes.each do |box|
      place_box(new_world, box, box.row, box.column)
    end

    @swarms.each do |swarm|
      swarm.each do |agent|
        perform_action(new_world, agent)
      end
    end

    @world = new_world
  end

  def perform_action(new_world, agent)
    row, col = [agent.row, agent.column]
    old_row, old_col = [row, col]

    # TODO: Pass the agent its local map
    action = agent.action({})

    case action
    when :north
      row -= 1 unless row == 0
    when :south
      row += 1 unless row == @rows - 1
    when :west
      col -= 1 unless col == 0
    when :east
      col += 1 unless col == @columns - 1
    end
    # TODO: Diagonals?

    new_world[old_row][old_col].delete(agent)
    new_world[row][col] << agent
    agent.location=([row, col])
  end
end
