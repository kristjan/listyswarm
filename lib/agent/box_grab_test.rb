class Agent::BoxGrabTest < Agent

  def action
    # I got a box!
    if sensors.have_box?
      @had_box = true
      return towards_spawn_point.select{|dir| can_move?(dir)}.shuffle.first
    end

    # Can I get a box?
    on_top_of_box = sensors.vision(0, 0).any? {|sprite| sprite.is_a?(Box) }
    return :pickup_box if on_top_of_box && !sensors.have_box? && !@had_box

    # Let's look for a box
    return away_from_spawn_point.select{|dir| can_move?(dir)}.shuffle.first
  end

  def towards_spawn_point
    [].tap do |dirs|
      dirs << (spawn_point.on_north_edge? ? :north : :south)
      dirs << (spawn_point.on_west_edge?  ? :west  : :east)
    end
  end

  def away_from_spawn_point
    [:north, :south, :east, :west] - towards_spawn_point
  end

end
