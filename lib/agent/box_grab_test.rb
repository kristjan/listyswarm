class Agent::BoxGrabTest < Agent

  BIAS_WEIGHT = 3

  def action
    @bias ||= [:horizontal, :none, :vertical].sample
    @bias_weight ||= rand(5)

    # I got a box!
    if sensors.have_box?
      return :drop_box if on_spawn_point?
      return towards_spawn_point.select{|dir| can_move?(dir)}.shuffle.first
    end

    # I'm on a box!
    on_top_of_box = sensors.vision(0, 0).any? {|sprite| sprite.is_a?(Box) }
    return :pickup_box if !sensors.have_box? && on_top_of_box && !on_spawn_point?

    # I can see a box!
    boxes = sensors.boxes
    if boxes.any?
      box_coords = boxes.first
      unless sensors.vision(*box_coords).detect{|sprite| sprite == spawn_point}
        return towards_box(box_coords)
      end
    end

    # Let's look for a box
    return away_from_spawn_point.select{|dir| can_move?(dir)}.shuffle.first
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
