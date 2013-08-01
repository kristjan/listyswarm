require 'pry'

class AgentBehavior::Librarian < AgentBehavior
  def action
    # I got a box!
    if sensors.have_box?
      return :drop_box if on_spawn_point? || nearby_box_chain?
      return towards_coords_offset(sensors.friendly_spawn_dir)
    end

    # I'm on a box!
    if !sensors.have_box? && on_box?
      return :pickup_box
    end

    # I can see a box!
    box_coords = sensors.boxes.detect do |possible_coords|
      sensors.vision(*possible_coords).select(&:box?).detect do |box|
        !box.owned_by?(self)
      end
    end

    if box_coords
      return towards_coords_offset(box_coords) rescue binding.pry
    end

    # Let's look for a box
    return towards_coords_offset(sensors.foe_spawn_dirs[side_to_attack])
  end

  # Returns the team string of the side to attack.
  def side_to_attack
    if sensors.foe_teams.length > 0
      # we really wish we could just attack the closest enemy, but we don't
      # technically know that.  so we just randomly distribute across agents
      i = sensors.agent_id % sensors.foe_teams.length
      sensors.foe_teams[i]
    else
      nil
    end
  end

  def nearby_box_chain?
    Coordinate::DIRECTIONS.any? do |direction|
      coords = Coordinate.neighbor([0, 0], direction)
      sensors.vision(*coords).select(&:box?).any? do |box|
        box.owned_by?(self)
      end
    end
  end
end
