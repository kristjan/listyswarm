require 'spawn'

class Spawn::InstantSpawn < Spawn
  def spawn(world, new_world, player)
    player.spawn_queue.each do |agent|
      world.class.respawn(new_world, agent)
      player.spawn(agent)
    end
  end
end
