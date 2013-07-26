require 'active_support/inflector'

require 'agent'
require 'loader'
require 'player'
require 'world'

class Universe
  attr_reader :options, :players, :ticks, :world

  TEAM_LABELS = %w[x o s w]

  def initialize(options)
    puts options.inspect
    @options = options
    @world = world_class.new(options)
    @ticks = 0
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

    @victory = Loader.load_class(:victory,
      options[:victory][:name]
    ).new(self, options[:victory][:params])

    @logger = Loader.load_class(:logger, options[:logger]).new
  end

  def start
    puts "BANG. #{world.rows}x#{world.columns} Universe begins."
    puts "#{players.size} players:"
    players.each do |player|
      puts "\t#{player.agent.class.name} (#{player.swarm.size})"
    end

    puts 'Start', world, nil
    begin
      world.tick
      @ticks += 1
      puts nil, "Tick #{@ticks}", world
      @logger.log(self)
    end until @victory.done?
    winners = @victory.winners
    puts winners.size > 1 ? "It's a tie!" : "We have a winner!"
    max_agent_length = @players.map{|player| player.agent.name.length}.max
    @players.sort_by{|player| -player.score}.each do |player|
      puts [
        player.team,
        player.agent.name.ljust(max_agent_length + 2),
        player.score.to_s.rjust(5)
      ].join(' ')
    end
  end

  private

  def world_class
    @world_class ||= Loader.load_class(:world, options[:world])
  end
end
