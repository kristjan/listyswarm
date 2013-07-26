class BoxDropper::ClusterDrop < BoxDropper
  def initialize(options)
    @frame = 0
    @period = options['period'] || 100
    @drop_size = options['drop_size'] || 10
    @drop_radius = options['drop_radius'] || 5
  end

  # returns a list of boxes and the coordinates that each should be placed
  def tick(world)
    boxes_to_make = []

    if @frame % @period == 0
      row = Universe::RNG.rand(world.length)
      col = Universe::RNG.rand(world.first.length)

      puts "Dropping #{@drop_size} boxes at #{[row, col]}"
      offsets = random_offsets(@drop_radius, @drop_size)

      boxes_to_make = offsets.map do |row_offset, col_offset|
        [Box.new, [row + row_offset, col + col_offset]]
      end
    end

    @frame += 1
    boxes_to_make
  end

  def random_offsets(radius, count)
    (0...count).map do
      [Universe::RNG.rand(radius * 2 + 1) - radius,
       Universe::RNG.rand(radius * 2 + 1) - radius]
    end
  end
end
