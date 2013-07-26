require 'active_support/inflector'
require 'curses'

require 'agent'
require 'loader'
require 'log'
require 'player'
require 'world'

class Universe
  include Curses

  attr_reader :options, :players, :ticks, :world

  TEAM_LABELS = %w[x o s w]

  def initialize(options)
    @options = options
    self.class.const_set('RNG', Random.new(options[:random_seed]))
    @world = world_class.new(options)
    @ticks = 0
    @players = []
    Log.options = options[:log]

    options[:agent_behaviors].each_with_index do |agent_behavior, i|
      players << Player.new(
        agent_behavior:      agent_behavior,
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
    init_screen
    crmode
    begin
      Log.log("Tick #{@ticks}")
      print_screen
      world.tick
      @ticks += 1
      @logger.log(self)
      getch if options[:newline_wait]
      sleep(options[:sleep_seconds] || 0)
    end until @victory.done?
    print_screen
    getch
  end

  private

  def build_header
    top_line = "Tick #{@ticks}"

    @victory.update_scores
    if @victory.done?
      winners = @victory.winners
      top_line << ' - ' + (winners.size > 1 ? "It's a tie!" : "We have a winner!")
    end

    lines = [top_line]

    max_agent_length = @players.map{|player| player.agent_behavior.name.length}.max
    @players.sort_by{|player| -player.score}.each do |player|
      lines << [
        player.team,
        player.agent_behavior.name.ljust(max_agent_length + 2),
        player.score.to_s.rjust(5)
      ].join(' ')
    end

    lines
  end

  def print_screen
    setpos(0, 0)
    addstr(world.to_s)
    header = build_header
    display_height = (@world.rows - header.size) / 2
    header.each_with_index do |line, i|
      setpos(display_height + i, @world.columns + 10)
      addstr(line)
    end
    setpos(@world.rows + 1, @world.columns + 1)
    refresh
  end

  def world_class
    @world_class ||= Loader.load_class(:world, options[:world])
  end
end
