require 'active_support/inflector'

require 'agent'
require 'world'

class Universe
  attr_reader :swarms, :options, :world

  TEAM_LABELS = %w[x o s w]

  def initialize(options)
    @options = options
    @agent_brains = options[:agent_brains].map do |agent_name|
      load_class(:agent, agent_name)
    end
    @swarms = []
    @agent_brains.zip(TEAM_LABELS).each_with_index do |(brain, team), i|
      swarms[i] = options[:agent_count].to_i.times.map { brain.new(team) }
    end
    @world = world_class.new(options.merge(swarms: swarms))
  end

  def start
    puts "BANG. #{world.rows}x#{world.columns} Universe begins."
    puts "#{swarms.size} swarms:"
    swarms.each do |swarm|
      puts "\t#{swarm.first.class.name} (#{swarm.size})"
    end

    puts 'Start:', world, nil
    begin
      world.tick
      puts nil, world
      STDIN.gets
    end while true
  end

  private

  def load_class(prefix, name)
    class_name = "#{prefix}/#{name.underscore}"
    @loaded_classes ||= {}
    @loaded_classes[class_name] ||= begin
      require class_name
      Object.const_get(prefix.to_s.camelize).const_get(name.camelize)
    end
  end

  def world_class
    @world_class ||= load_class(:world, options[:world])
  end
end
