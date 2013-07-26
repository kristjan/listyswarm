require 'sprite'

class Agent < Sprite
  attr_reader :id, :player, :agent_behavior
  attr_accessor :box

  def initialize(player, id)
    @player = player
    @id = id
    @agent_behavior = player.agent_behavior.new(player.team)
  end

  def has_box?
    !@box.nil?
  end

  def display_char
    if has_box?
      team.upcase
    else
      team
    end
  end

  def display_priority
    has_box? ? 11 : 10
  end

  def spawn_point
    player.spawn_point
  end

  def team
    player.team
  end
end
