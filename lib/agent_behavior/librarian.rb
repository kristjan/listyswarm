require 'pry'

class AgentBehavior::Librarian < AgentBehavior
  def action

    # I got a box!
    if sensors.have_box?
      return :drop_box if on_spawn_point? || nearby_box_chain?
      return dodge(towards_coords_offset(sensors.friendly_spawn_dir, :cutoff => 0.5))
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
      return dodge(towards_coords_offset(box_coords))
    end

    # Let's look for a box
    return dodge(towards_coords_offset(sensors.foe_spawn_dirs[side_to_attack], :seed => self.hash))
  end

  # Given a 2-d vector of a coordinate offset, return
  # the behavior direction that would get you closer to that.
  #
  def towards_coords_offset(coords_offset, options=nil)
    options ||= {}
    if options[:seed].nil?
      options[:seed] = Universe::RNG.rand(1000)
    end

    if options[:cutoff].nil? && !options[:seed].nil?
      options[:cutoff] = ((options[:seed] % 1001) / 1000.0) * 2.0 - 1.0 # ranges [-1.0, 1.0]
    end

    return nil if coords_offset == [0,0]
    row, col = coords_offset # Relative


    diff = row.to_f.abs - col.to_f.abs # ranges [-1.0, 1.0]

    if diff > options[:cutoff]
      return :north if row < 0
      return :south if row > 0
    else
      return :west if col < 0
      return :east if col > 0
    end
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

  def dodge(action)
    if Coordinate::DIRECTIONS.include?(action)
      return action if box_visible?

      unsafe_coords = get_neighbors([0,0]).select { |coords| !is_safe(coords) }

      if unsafe_coords.include?(Coordinate.neighbor([0,0], action))
        dirs = (get_neighbors([0,0]) - unsafe_coords).shuffle

        if dirs.empty?
          return action
        else
          #pick a random safe square and go there
          return Coordinate.action_by_coord(dirs.first)
        end
      end
    end

    return action
  end

  def is_safe(coords)
    foe_coords = sensors.enemies
    return true if foe_coords.length == 0

    foe_coords.none? do |row, col|
      World.manhattan_distance(coords[0], coords[1], row, col) <= 1
    end
  end

  def get_neighbors(coords)
    neighbors = Coordinate::DIRECTIONS.map {|a| coords = Coordinate.neighbor([0, 0], a) }
    neighbors.select!{|c| !sensors.vision(*c).any?(&:wall?) }
    neighbors
  end

  def pv
    puts sensors.vision_to_s
  end

  def box_visible?
    box_coords = sensors.boxes.detect do |possible_coords|
      sensors.vision(*possible_coords).select(&:box?).detect do |box|
        !box.owned_by?(self)
      end
    end
    !box_coords.nil?
  end
end
