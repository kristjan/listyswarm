class AgentBehavior::GuardingAgent < AgentBehavior
  def action
    @role ||= pick_role
    send("#{@role}_action")
  end

  def roaming_guard_action
    # Get 'em!
    all_enemy_coords = sensors.enemies
    if all_enemy_coords.any?
      return towards(all_enemy_coords.first)
    end

    # Repair the line
    gather = gather_box
    return gather if gather

    # Patrol
    on = sensors.vision(0, 0)
    if on.detect{|sprite| sprite.is_a?(Box) && sprite.owned_by?(self)}
      return :east
    elsif !near?(Wall, :north)
      return :north
    else
      return :west
    end
  end

  def stationary_guard_action
    # Get 'em!
    all_enemy_coords = sensors.enemies
    if all_enemy_coords.any?
      return towards(all_enemy_coords.first)
    end

    # Repair the line
    gather = gather_box
    return gather if gather

    # Return to base
    unless on_spawn_point?
      return towards_spawn_point.select{|dir| can_move?(dir)}.first
    end
  end

  def gatherer_action
    @bias ||= [:horizontal, :none, :vertical].sample
    @bias_weight ||= Universe::RNG.rand(5)

    add_debug("friendly spawn dir: #{sensors.friendly_spawn_dir}\n")
    sensors.foe_spawn_dirs.keys.map do |team|
      add_debug("enemy dir: #{sensors.foe_spawn_dirs[team]}\n")
    end

    add_debug(sensors.vision_to_s)

    gather = gather_box
    return gather if gather

    # Let's look for a box
    return away_from_spawn_point.select{|dir| can_move?(dir)}.shuffle.first
  end

  private

  def gather_box
    # I got a box!
    if sensors.have_box?
      return :drop_box if on_spawn_point? || near_box_chain?
      return towards_spawn_point.select{|dir| can_move?(dir)}.first
    end

    # I'm on a box!
    on_box = sensors.vision(0, 0).select(&:box?).any? do |box|
      !box.owned_by?(self)
    end
    return :pickup_box if on_box

    # I can see a box!
    all_box_coords = sensors.boxes
    box_coords = all_box_coords.detect do |possible_coords|
      sensors.vision(*possible_coords).select(&:box?).detect do |box|
        !box.owned_by?(self)
      end
    end
    return towards(box_coords) if box_coords
  end

  def pick_role
    @@agents ||= 0
    @@guards ||= 0

    if @@agents == 0
      @@agents += 1
      return :gatherer
    end

    case @@guards
    when 0
      @@guards += 1
      :roaming_guard
    when 1
      @@guards += 1
      :stationary_guard
    else
      :gatherer
    end
  end

  def spawn_point
    sensors.spawn_point
  end

  def near_box_chain?
    towards_spawn_point.detect do |direction|
      coords = Coordinate.neighbor([0, 0], direction)
      sensors.vision(*coords).select(&:box?).any? do |box|
        box.owned_by?(self)
      end
    end
  end

  def towards(coords)
    row, col = coords # Relative
    case
    when row < 0 then :north
    when row > 0 then :south
    when col < 0 then :west
    when col > 0 then :east
    end
  end

  def towards_spawn_point
    [].tap do |dirs|
      dirs << (spawn_point.on_north_edge? ? :north : :south)
      dirs << (spawn_point.on_west_edge?  ? :west  : :east)
    end
  end

  def away_from_spawn_point
    dirs = [:north, :south, :east, :west] - towards_spawn_point
    # Amplify our directional bias
    case @bias
    when :none       then dirs
    when :vertical   then dirs.concat((dirs - [:east, :west]) * @bias_weight)
    when :horizontal then dirs.concat((dirs - [:north, :south]) * @bias_weight)
    end
  end
end
