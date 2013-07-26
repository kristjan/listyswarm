class Universe
  def initialize(options)
    @options = options
    @world = Array.new(rows, Array.new(columns))
  end

  def rows
    @options[:rows]
  end

  def columns
    @options[:columns]
  end

  def start
    puts "BANG. #{rows}x#{columns} Universe begins."
  end
end
