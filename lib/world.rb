class World
  attr_reader :rows, :columns

  def initialize(rows, columns)
    @rows = rows
    @columns = columns
    @world = Array.new(@rows, Array.new(@columns))
  end

  def tick
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end
end
