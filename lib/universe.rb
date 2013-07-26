require 'active_support/inflector'

require 'agent'
require 'world'

class Universe
  attr_reader :agents, :options, :world

  def initialize(options)
    @options = options
    @world = world_class.new(options[:rows], options[:columns])
    @world.place_boxes(options[:boxes].to_i)
    @agents = options[:agents].map {|agent_name| load_agent(agent_name) }
  end

  def start
    puts "BANG. #{world.rows}x#{world.columns} Universe begins."
    puts world
    puts "#{agents.size} agents:"
    agents.each do |agent|
      puts "\t#{agent.class.name}"
    end
  end

  private

  def load_agent(name)
    load_class(:agent, name).new
  end

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
