require 'active_support/inflector'

require 'agent'
require 'loader'
require 'player'
require 'world'

class Universe
  attr_reader :options, :players, :world

  TEAM_LABELS = %w[x o s w]

  def initialize(options)
    @options = options
    @world = world_class.new(options)
    @players = []

    options[:agents].each_with_index do |agent, i|
      players << Player.new(
        agent:      agent,
        swarm_size: options[:swarm_size],
        team:       TEAM_LABELS[i],
      ).tap do |player|
        @world.add_player(player)
      end
    end
  end

  def start
    puts "BANG. #{world.rows}x#{world.columns} Universe begins."
    puts "#{players.size} players:"
    players.each do |player|
      puts "\t#{player.agent.class.name} (#{player.swarm.size})"
    end
    begin
      puts nil, world
      world.tick
    end while true
  end

  private

  def world_class
    @world_class ||= Loader.load_class(:world, options[:world])
  end
end
