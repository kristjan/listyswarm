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
    @world = world_class.new(self, options)
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
      Universe.clear_debug
      world.tick
      @ticks += 1
      @logger.log(self)
      getch if options[:newline_wait]
      sleep(options[:sleep_seconds] || 0)
    end until @victory.done?
    print_screen
    getch
  end

  def game_stats
    {}.tap do |stats|
      stats[:tick] = @ticks
      @players.each do |player|
        stats[player.team] = {
          agent:  player.agent_behavior.name,
          avatar: player.agent_behavior.avatar,
          swarm:  player.swarm.size,
          score:  player.score
        }
      end
    end
  end

  private

  def build_header
    update_frequency = options.fetch(:score_update_frequency, 1).to_i
    @victory.update_scores if @ticks % update_frequency == 0

    max_agent_length = @players.map{|player| player.agent_behavior.name.length}.max
    header = %w[Team Behavior Agents Score]
    widths = [6, max_agent_length + 2, 8, 7]

    stats = game_stats

    lines = []
    lines << header.zip(widths).map {|data, width| data.to_s.ljust(width)}
    @players.sort_by{|player| -stats[player.team][:score]}.each do |player|
      team = player.team
      lines << [
        team,
        stats[team][:agent],
        stats[team][:swarm],
        stats[team][:score]
      ].zip(widths).map do |data, width|
        data.to_s.ljust(width)
      end
    end

    top_line = "Tick #{stats[:tick]}"
    if @victory.done?
      winners = @victory.winners
      top_line << ' - ' + (winners.size > 1 ? "It's a tie!" : "We have a winner!")
    end
    lines.unshift([top_line, ''])

    lines = lines.map(&:join)

    lines
  end

  def print_screen
    setpos(0, 0)
    addstr(world.to_s)
    sidebar_lines = build_header

    #print debug info on the side column
    if Universe.debug_str
      sidebar_lines += Universe.debug_str.split("\n")
    end

    display_height = [(@world.rows - sidebar_lines.size) / 2, 0].max
    sidebar_lines.each_with_index do |line, i|
      setpos(display_height + i, @world.columns + 10)
      addstr(line)
    end
    setpos(@world.rows + 1, @world.columns + 1)
    refresh
  end

  def self.clear_debug
    Universe.debug_str = nil
  end

  def self.debug_str=(str)
    @debug_str = str
  end

  def self.debug_str
    @debug_str ||= ''
  end

  def world_class
    @world_class ||= Loader.load_class(:world, options[:world])
  end
end
