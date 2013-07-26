class World::SynchronizedWorld < World
  def tick
    #create a new empty world
    new_world = build_world

    @boxes.each do |box|
      place_box(new_world, box, box.row, box.column)
    end

    @spawn_points.each do |point|
      new_world[point.row][point.column] << point
    end

    @players.each do |player|
      player.swarm.each do |agent|
        perform_action(@world, new_world, agent)
      end
    end

    rectify(new_world)

    @world = new_world
  end

  private

  def perform_action(old_world, new_world, agent)
    row, col = [agent.row, agent.column]
    old_row, old_col = [row, col]

    # TODO: vision should be a part of a larger sensor suite
    vision = @vision_capture.generate_vision(self, agent)

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

  def rectify(world)
    world.each do |row|
      row.each do |items|
        combatants = items.select do |item|
          item.is_a?(Agent)
        end.group_by(&:player).to_a.sort_by{|player, agents| agents.size}

        if combatants.size > 1
          runner_up, winner = combatants.last(2)
          body_count = runner_up.last.size # agent count
          killed = combatants.map{|player, agents| agents.first(body_count)}
          killed.flatten.each{|agent| self.class.respawn(world, agent) }
        end
      end
    end
  end
end
