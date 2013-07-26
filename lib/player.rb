require 'loader'
require 'log'

class Player
  attr_reader :agent_behavior, :spawn_point, :swarm, :team
  attr_accessor :spawn_queue, :score

  def initialize(options)
    @team = options[:team]
    @agent_behavior = Loader.load_class(:agent_behavior, options[:agent_behavior])
    @spawn_queue = options[:swarm_size].to_i.times.map do |id|
      Agent.new(self, id)
    end
    @swarm = []
  end

  def kill(agent)
    Log.log "#{team} died"
    @swarm.delete(agent)
    agent.location = nil
    @spawn_queue << agent
  end

  def spawn(agent)
    Log.log "#{team} spawning"
    @spawn_queue.delete(agent)
    @swarm << agent
  end

  def spawn_point=(point)
    raise "SpawnPoint can not be set twice." if @spawn_point
    @spawn_point = point
  end
end
