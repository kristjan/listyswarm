class World::SynchronizedWorld < World

  # Within this method, @world shouldn't be modified.  rather,
  # new_world should be appended to.
  def tick
    #create a new empty world
    new_world = build_world


    @players.each do |player|
      player.swarm.each do |agent|
        perform_action(new_world, agent)
      end
    end

    #only copy boxes that aren't being held by an agent
    @boxes.each do |box|
      if !box.is_held
        puts "placing box #{[box.row, box.column]}"
        place_box(new_world, box, box.row, box.column)
      end
    end

    @world = new_world
  end

  def perform_action(new_world, agent)
    row, col = [agent.row, agent.column]
    old_row, old_col = [row, col]

    sensors = Sensors.create(self, agent)

    action = agent.action(sensors)

    case action
    when :north
      row -= 1 unless row == 0
    when :south
      row += 1 unless row == @rows - 1
    when :west
      col -= 1 unless col == 0
    when :east
      col += 1 unless col == @columns - 1
    when :pickup_box
      pickup_box(new_world, agent)
    when :drop_box
      drop_box(new_world, agent)
    end

    new_world[old_row][old_col].delete(agent)
    new_world[row][col] << agent
    agent.location=([row, col])
  end

  def pickup_box(new_world, agent)
    if agent.has_box?
      puts "Can't pickup box"
      return
    end

    puts "Picked up box"

    #find a box that isn't held
    box = world[agent.row][agent.column].find do |sprite|
      sprite.is_a?(Box) && !sprite.is_held?
    end

    if !box.nil?
      box.is_held = true
      agent.box = box
    end
  end

  def drop_box(new_world, agent)
    if !agent.has_box?
      puts "Can't drop box"
      return
    end

    puts "Dropping box"

    agent.box.is_held = false
    place_box(new_world, agent.box, agent.row, agent.column)
    agent.box = nil
  end

end
