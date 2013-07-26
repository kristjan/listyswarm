require 'sprite'

class Agent < Sprite
  attr_reader :id, :team
  attr_accessor :box

  def initialize(team, id)
    @team = team
    @id = id
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

  def action(state)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
