require 'loader'

class Player
  attr_reader :agent, :swarm, :team

  def initialize(options)
    @team = options[:team]
    @agent = Loader.load_class(:agent, options[:agent])
    @swarm = options[:swarm_size].to_i.times.map do |id|
      @agent.new(@team, id)
    end
  end
end
