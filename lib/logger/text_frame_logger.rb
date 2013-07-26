require 'fileutils'

class Logger::TextFrameLogger < Logger

  def frame(universe)
    universe.world.to_s
  end

end
