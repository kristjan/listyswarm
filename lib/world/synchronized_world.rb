class World::SynchronizedWorld < World

  # Within this method, @world shouldn't be modified.  rather,
  # new_world should be appended to.
  def tick
    #create a new empty world
    new_world = build_world


    @spawn_points.each do |point|
      new_world[point.row][point.column] << point
    end

    @players.each do |player|
      player.swarm.each do |agent|
        perform_action(new_world, agent)
      end
    end

    #only copy boxes that aren't being held by an agent
    @boxes.each do |box|
      if !box.is_held
        place_box(new_world, box, box.row, box.column)
      end
    end

    rectify(new_world)

    @world = new_world
  end

  private

  def perform_action(new_world, agent)
    row, col = [agent.row, agent.column]
    old_row, old_col = [row, col]

    agent.sensors = Sensors.create(self, agent)

    action = agent.action
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
    return if agent.has_box?

    #find a box that isn't held
    box = world[agent.row][agent.column].find do |sprite|
      sprite.is_a?(Box) && !sprite.is_held?
    end

    if !box.nil?
      box.is_held = true
      agent.box = box
      box.owner = nil # Only owned when part of your chain
    end
  end

  def drop_box(new_world, agent)
    return unless agent.has_box?

    agent.box.is_held = false
    place_box(new_world, agent.box, agent.row, agent.column)
    agent.box = nil
  end

  def rectify(world)
    fight(world)
    assign_boxes(world)
  end

  def assign_boxes(world)
    @boxes.each{|box| box.owner = nil}
    @spawn_points.each do |spawn|
      assign_box_chain(world, spawn.location, spawn.player)
    end
  end

  def assign_box_chain(world, coord, player)
    row, col = coord
    return if row < 0 || col < 0 || row >= @rows || col >= @columns

    boxes = world[row][col].select(&:box?).select{|box| box.owner.nil?}
    return if boxes.empty?

    boxes.each {|box| box.owner = player}
    Coordinate::DIRECTIONS.each do |direction|
      assign_box_chain(world, Coordinate.neighbor(coord, direction), player)
    end
  end

  def fight(world)
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
