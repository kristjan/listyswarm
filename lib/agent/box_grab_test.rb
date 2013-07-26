class Agent::BoxGrabTest < Agent
  def action(sensors)
    on_top_of_box = sensors.vision(0, 0).any? {|sprite| sprite.is_a?(Box) }

    @had_box = true if sensors.have_box?

    if !sensors.have_box? && on_top_of_box && @had_box.nil?
      return :pickup_box
    end

    return :north if @had_box.nil? && !sensors.have_box?

    if sensors.have_box?

      to_right = sensors.vision(0, 1)
      if !to_right.nil? && to_right.first.is_a?(Wall)
        return :drop_box
      else
        return :east
      end
    end

    return :south if @had_box == true && !sensors.have_box?
  end

end
