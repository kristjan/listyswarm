require 'loader'

class Player
  attr_reader :agent_behavior, :spawn_point, :swarm, :team
  attr_accessor :score

  def initialize(options)
    @team = options[:team]
    @agent_behavior = Loader.load_class(:agent_behavior, options[:agent_behavior])
    @swarm = options[:swarm_size].to_i.times.map do |id|
      Agent.new(self, id)
    end
  end

  def spawn_point=(point)
    raise "SpawnPoint can not be set twice." if @spawn_point
    @spawn_point = point
  end
end
