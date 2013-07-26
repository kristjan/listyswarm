require 'active_support/inflector'

require 'world'

class Universe
  attr_reader :options, :world

  def initialize(options)
    @options = options
    @world = world_class.new(options[:rows], options[:columns])
  end

  def start
    puts "BANG. #{world.rows}x#{world.columns} Universe begins."
  end

  private

  def world_class
    @world_class ||= begin
      require "world/#{options[:world].underscore}"
      World.const_get(options[:world])
    end
  end

end
