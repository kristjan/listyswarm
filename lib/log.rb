module Log
  @log = File.open('./game.log', 'a')
  @log.sync = true

  def self.options=(options)
    @options = options
  end

  def self.log(*msgs)
    return unless @options[:enabled]
    msgs.each do |msg|
      @log.puts msg
      @log.flush
    end
  end
end
