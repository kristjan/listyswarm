require 'set'

require 'box'

class World
  attr_reader :options, :boxes, :players, :world
  attr_reader :rows, :columns

  def initialize(options)
    @options        = options
    @rows           = options[:rows]
    @columns        = options[:columns]
    @players        = []
    @spawn_points   = []
    @boxes          = []
    @box_droppers = make_box_droppers(options[:box_droppers])
    @world          = build_world
    place_boxes(options[:boxes].to_i)
  end

  def make_box_droppers(box_droppers)
    box_droppers.map do |_options|
      dropper_class = Loader.load_class(:box_dropper, _options['name'])
      dropper_class.new(_options)
    end
  end

  def [](row, col)
    @world[row][col]
  end

  def add_player(player)
    spawn_point = pick_spawn_point(@players.size)
    @spawn_points << spawn_point
    player.spawn_point = spawn_point
    spawn_point.player = player
    @world[spawn_point.row][spawn_point.column] << spawn_point
    @players << player
    place_swarm(player)
  end

  def to_s(border=true)
    self.class.world_to_s(@world, border)
  end

  def self.world_to_s(world, border=true)
    "".tap do |out|
      out << '+' + '-' * world.length + "\n" if border
      world.each_with_index do |row, i|
        out << '|' if border
        row.each do |things|
          out << character_for(things)
        end
        out << "\n"
      end
    end
  end

  # returns the sprites at the row and column.  if the row and column are
  # outside the range of the world, return a wall.
  def get_sprites(world_arr, row, col)
    if row < 0 || col < 0 || row >= @rows || col >= @columns
      Array.new([Wall.new])
    else
      world[row][col]
    end
  end

  def self.add_sprite(world_arr, sprite, row, col)
    if row.nil? || col.nil?
      raise ArgumentError.new
    end

    sprite.row = row
    sprite.column = col

    rows = world_arr.length
    cols = world_arr.first.length

    return false if row < 0 || row >= rows || col < 0 || col >= cols


    if world_arr[sprite.row][sprite.column].nil?
      world_arr[sprite.row][sprite.column] = []
    else
      world_arr[sprite.row][sprite.column] << sprite
    end

    true
  end

  def tick
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

  private

  def self.respawn(world, agent)
    world[agent.row][agent.column].delete(agent) if agent.location
    row, col = agent.player.spawn_point.location
    world[row][col] << agent
    agent.location = [row, col]
  end

  def build_world
    make_grid(@rows, @columns)
  end

  def make_grid(row_count, column_count)
    Array.new(row_count) { Array.new(column_count) { Set.new } }
  end

  def self.character_for(things)
    item = sort_things(things).first
    if item.is_a?(Sprite)
      item.display_char
    else
      ' '
    end.to_s
  end

  def place_swarm(player)
    player.swarm.each {|agent| self.class.respawn(world, agent) }
  end

  def place_box(world, box, row, column)
    box.is_held = false
    self.class.add_sprite(world, box, row, column)
  end

  def place_boxes(count)
    random_coordinates(count).each do |row, col|
      @boxes << Box.new
      place_box(@world, @boxes.last, row, col)
    end
  end

  def random_coordinates(count)
    row_coords = (0...@rows).to_a.shuffle
    col_coords = (0...@columns).to_a.shuffle
    row_coords.zip(col_coords).first(count)
  end

  SPAWN_LABELS = (1..4).to_a
  def pick_spawn_point(index)
    coords = [
      [0, 0],
      [@rows - 1, @columns - 1],
      [0, @columns - 1],
      [@rows - 1, 0]
    ][index]

    SpawnPoint.new(SPAWN_LABELS[index], coords)
  end

  PRECEDENCE = %w[SpawnPoint Agent Box NilClass]
  def self.sort_things(things)
    things.sort_by do |thing|
      PRECEDENCE.index(thing.class.name.split('::').first)
    end
  end

end
