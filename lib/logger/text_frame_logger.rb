require 'fileutils'

class Logger::TextFrameLogger < Logger

  def frame(universe)
    [
      universe.game_stats.to_json,
      universe.world.to_s(false)
    ].join("\n")
  end

end
