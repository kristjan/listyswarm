class AgentBehavior::TornadoAgent < AgentBehavior

  BEHAVIOR_CLASSES = {
    :tornado => 0.5,
    :gather => 0.5
  }

  def action
    add_debug("class: #{behavior_class}")
    init_gathering_agent

    if sensors.foe_teams.length == 0
      #if we don't have foes, then just turn into a gatherer
      return @gathering_agent.action
    end

    return case behavior_class
      when :tornado
        tornado_behavior
      when :gather
        @gathering_agent.action
    end
  end

  def tornado_behavior
    if have_box?
      return @gathering_agent.action
    end

    if !in_tornado? && !have_box?
      #walk home
      return towards_coords_offset(sensors.friendly_spawn_dir, false)
    end

    if on_spawn_point? && !ready_to_leave? && !have_box?
      #wait for others to return
      return nil
    end

    if on_spawn_point? && ready_to_leave? && !have_box?
      return towards_coords_offset(sensors.foe_spawn_dirs[side_to_attack], false)
    end

    #if we're out on the prowl
    if in_tornado? && !on_spawn_point?
      if on_box?
        return :pickup_box
      end

      if surrounded_by_enemy_boxes?
        box_coords = notice_box
        return towards_coords_offset(box_coords, false)
      else
        #walk toward the enemy
        return towards_coords_offset(sensors.foe_spawn_dirs[side_to_attack], false)
      end
    end

    return @gathering_agent.action
  end

  def on_enemy_spawn?
    sensors.vision(0,0).any? do |sprite|
      sprite.is_a?(SpawnPoint) && sprite.player.team != team
    end
  end

  # Returns a single box location out of multiple possible. Should be
  # deterministic.
  def notice_box(max_distance = 10000)
    box_coords = sensors.boxes.detect do |possible_coords|
      sensors.vision(*possible_coords).select(&:box?).detect do |box|
        d = World.manhattan_distance(0, 0, box.row, box.column)
        !box.owned_by?(self) && (d <= max_distance)
      end
    end
  end

  def surrounded_by_enemy_boxes?
    count = 0
    radius = [2, sensors.vision_radius].min
    (-radius..radius).each do |row|
      (-radius..radius).each do |col|
        next if row == 0 && col == 0

        foe_boxes = sensors.vision(row, col).select do |s|
          s.box? && s.owner != nil && !s.owned_by?(self)
        end

        count += foe_boxes.length
      end
    end

    count > 3
  end

  def init_gathering_agent
    @gathering_agent ||= AgentBehavior::GathererAgent.new(team)
    @gathering_agent.sensors = sensors
  end

  # Used to differentiate agents into classes based on their id.
  def behavior_class
    cumulative = 0
    behavior = BEHAVIOR_CLASSES.keys.find do |behavior|
      cumulative += (BEHAVIOR_CLASSES[behavior] * 100.0).to_i
      sensors.agent_id.hash % 100 <= cumulative
    end

    behavior
  end

  # Returns the team string
  def side_to_attack
    if sensors.foe_teams.length > 0
      i = game_settings_hash % sensors.foe_teams.length
      sensors.foe_teams[i]
    else
      nil
    end
  end

  # How do you essentially get all of your agents to perform
  # the same random action?  well, they all share the same vision
  # so you can just hash that to get essentially a random number
  def viewport_hash
    hash = 0
    sensors.vision_array.each_with_index do |row, row_num|
      row.each_with_index do |sprites, col_num|
        sprites.each do |sprite|
          hash = hash ^ row_num.hash ^ col_num.hash ^ sprite.class.hash
        end
      end
    end
    hash
  end

  # Essentially generates a random number that will be the same across all
  # agents in the same game.
  def game_settings_hash
    sensors.swarm_size.hash ^ sensors.swarm_size.hash ^ sensors.foe_teams.length.hash
  end

  def count_friendlies
    friendlies = sensors.vision(0,0).select {|s| s.is_a?(Agent) && s.team == team}
    friendlies.length
  end

  def ready_to_leave?
    count_friendlies > sensors.swarm_size * BEHAVIOR_CLASSES[:tornado] * 0.8
  end

  def in_tornado?
    friendlies = sensors.vision(0,0).select {|s| s.is_a?(Agent) && s.team == team}
    #count_friendlies > [sensors.swarm_size * BEHAVIOR_CLASSES[:tornado] * 0.2, 2].max
    count_friendlies >= 2
  end
end
