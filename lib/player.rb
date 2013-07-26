require 'loader'

class Player
  attr_reader :agent, :spawn_point, :swarm, :team

  def initialize(options)
    @team = options[:team]
    @agent = Loader.load_class(:agent, options[:agent])
    @swarm = options[:swarm_size].to_i.times.map do |id|
      @agent.new(self, id)
    end
  end

  def spawn_point=(point)
    raise "SpawnPoint can not be set twice." if @spawn_point
    @spawn_point = point
  end
end
