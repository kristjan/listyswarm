class AgentBehavior::GathererAgent < AgentBehavior
  def action
    @bias ||= [:horizontal, :none, :vertical].sample
    @bias_weight ||= Universe::RNG.rand(5)

    Universe.debug_lines = []
    Universe.debug_lines << "friendly spawn dir: #{sensors.friendly_spawn_dir}"
    sensors.foe_spawn_dirs.keys.map do |team|
      Universe.debug_lines << "enemy dir: #{sensors.foe_spawn_dirs[team]}"
    end


    # I got a box!
    if sensors.have_box?
      return :drop_box if on_spawn_point? || near_box_chain?
      return towards_spawn_point.select{|dir| can_move?(dir)}.shuffle.first
    end

    # I'm on a box!
    on_top_of_box = sensors.vision(0, 0).select(&:box?).any? do |box|
      !box.owned_by?(self)
    end
    if !sensors.have_box? && on_top_of_box
      return :pickup_box
    end

    # I can see a box!
    all_box_coords = sensors.boxes
    box_coords = all_box_coords.detect do |possible_coords|
      sensors.vision(*possible_coords).select(&:box?).detect do |box|
        !box.owned_by?(self)
      end
    end

    if box_coords
      return towards_box(box_coords)
    end

    # Let's look for a box
    return away_from_spawn_point.select{|dir| can_move?(dir)}.shuffle.first
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

  def towards_box(coords)
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
