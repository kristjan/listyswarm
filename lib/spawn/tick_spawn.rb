require 'spawn'

class Spawn::TickSpawn < Spawn
  def initialize(options={})
    @data = {}
    super
  end

  def spawn(world, new_world, player)
    @data[player.team] ||= {
      ticks: 0,
      last_tick: 0
    }
    data = @data[player.team]
    data[:ticks] += 1
    ready = data[:ticks] >= data[:last_tick] + @options.fetch(:period, 1)
    if ready && player.spawn_queue.any?
      @options.fetch(:count, 1).times do
        agent = player.spawn_queue.pop
        world.class.respawn(new_world, agent)
        player.spawn(agent)
      end
      data[:last_tick] = data[:ticks]
    end
  end
end
