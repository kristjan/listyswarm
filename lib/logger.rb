class Logger

  LOG_DIR = "games"

  def initialize
    @game_id = self.class.next_id
    FileUtils.mkdir_p(self.class.log_path(@game_id))
  end

  def frame(universe)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__}"
  end

  def log(universe)
    File.open(self.class.log_path(@game_id, universe.ticks), 'w') do |file|
      file.puts frame(universe)
    end
  end

  private

  def self.log_path(game_id=nil, frame_id=nil)
    parts = ['.', LOG_DIR]
    if game_id == '*'
      parts << '*'
    else
      parts << game_id.to_s.rjust(10, '0') if game_id
      parts << frame_id.to_s.rjust(10, '0') if frame_id
    end
    File.join(parts)
  end

  def self.next_id
    (Dir[log_path('*')].map do |game|
      File.split(game).last.to_i
    end.max || 0) + 1
  end

end
