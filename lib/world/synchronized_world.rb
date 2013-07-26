class World::SynchronizedWorld < World
  def tick
    #create a new empty world
    new_world = build_world

    @boxes.each do |box|
      place_box(new_world, box, box.row, box.column)
    end

    @players.each do |player|
      player.swarm.each do |agent|
        perform_action(@world, new_world, agent)
      end
    end

    @world = new_world
  end

  def perform_action(old_world, new_world, agent)
    row, col = [agent.row, agent.column]
    old_row, old_col = [row, col]

    # TODO: vision should be a part of a larger sensor suite
    vision = @vision_capture.generate_vision(self, agent)
    #puts World.world_to_s(vision)

    action = agent.action({:vision => vision})

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

    new_world[old_row][old_col].delete(agent)
    new_world[row][col] << agent
    agent.location=([row, col])
  end
end
