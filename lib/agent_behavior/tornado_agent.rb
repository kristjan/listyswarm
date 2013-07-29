class AgentBehavior::TornadoAgent < AgentBehavior

  BEHAVIOR_CLASSES = [
    [:tornado, 80],
    [:defend, 20]
  ]

  def action
    add_debug("friendly spawn dir: #{sensors.friendly_spawn_dir}\n")
    sensors.foe_spawn_dirs.keys.map do |team|
      add_debug("enemy dir: #{sensors.foe_spawn_dirs[team]}\n")
    end
    add_debug(sensors.vision_to_s)

    weighted_randomizer([
      [50, ->{ add_debug('hello')}],
      [50, ->{ add_debug('goodbye')}]
    ])

    return :west
    #return call_behavior
  end

  # Used to differentiate agents into classes based on their id.
  def call_behavior
    cumulative = 0
    behavior = BEHAVIOR_CLASSES.find do |behavior_class|
      cumulative += behavior_class[1]
      sensors.agent_id.hash % 100 <= cumulative
    end[0]

    self.send("#{behavior}_action")
  end

  #
  def tornado_action

  end

  #
  def defend_action

  end

  def near_box_chain?
    towards_spawn_point.detect do |direction|
      coords = Coordinate.neighbor([0, 0], direction)
      sensors.vision(*coords).select(&:box?).any? do |box|
        box.owned_by?(self)
      end
    end
  end

end
