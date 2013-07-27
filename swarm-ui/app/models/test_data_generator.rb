module TestDataGenerator
  def self.generate(size = 5, ticks = 10)
    ticks.times do |tick|
      File.open("game_data_test/#{tick}", 'w+') do |file|
        cells = generate_random_cells(size)
        size.times do |row|
          size.times do |cell|
            #file << random_object(size, i)
            file << cells[(row*size)+cell]
          end
          file << "\n"
        end
      end
    end
  end

  def self.random_object(size, i)
    ['x', 'X', 'o', 'O', 'b', ' '][Random.new.rand(0...6)]
  end

  def self.generate_random_cells(size)
    key = {
      "x" => 8,
      "X" => 2,
      "o" => 7,
      "O" => 3,
      "b" => 5,
      " " => 75
    }

    cells = []
    key.each_pair do |object, portion|
      multi = ((size*size) * (portion/100.to_f)).to_i
      multi.times { cells << object }
    end

    while cells.length < (size*size)
      cells << ' '
    end

    key.keys.each do |k|
      objects = cells.select { |c| c == k }.count
    end

    cells.shuffle
  end
end
