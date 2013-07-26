require 'fileutils'

class Logger::NullLogger < Logger
  def initialize(); end
  def log(universe); end
end
