listyswarm
==========

ListySwarm is a 2-d world where you winning means programming from the 
bottom up. It is a competition that is designed to force 
you to find the set of simpler rules that when applied to each individual
agent will result in the optimal behavior for the entire swarm.  It is also
designed to be simple and fun to tinker with.


## Running the World

To start the simulation, just call ```run``` from the command line and
pass a path to a configuration file.

```./run ./configs/basic.json```

The configuration file tells the engine what rules to use and what behavior
classes to run.


##Writing Your Own Swarm AI

Writing the simplest swarm AI takes only a few minutes to create.  You simply
create a subclass of the ```BehaviorAgent``` class and implement the ```#action```
method.  See ```lib/agent_behaviors/``` for examples of agents that have already
been written.

The execution model is simple.  On each iteration of the simulation, the ```#action```
method run for every agent to determine what its next move will be.  This means that
the ```#action``` method is run only within the context of a single agent at a time.
Further, In this method you can't directly see what other agents going to do, you can't interact 
with any global state.  These limitations are what makes this 


```
class Agent::RandomAgent < BehaviorAgent
  def action
    [:north, :south, :east, :west].shuffle.first
  end
end
```

###Available Actions

In keeping with our goal of simplicity, during the execution of an agent's 
```#action``` method, there are only six possible behaviors that you can return.

#### Directions

```:north```, ```:south```, ```:east```, ```:west```

Returning this from your behavior method will cause your agent to move in that
direction for the next iteration.

#### Interacting with Boxes

If you are standing directly on top of a box, you can return ```:pickup_box``` to cause
your agent to pick that box up.  If you are currently holding a box and you return 
```:drop_box```, your agent will drop the box directly where you are standing.


###Available Sensors

In the RandomAgent example shown above we didn't use any input from the outside 
world to determine what our agent should do.  Of course, this is going to
be non-optimal.  In fact, each agent has a list of various input data that 
it can use and you can access all of them via the ```sensors``` object.


#### Vision

This is the most important sensor that you have access to.  Each agent can 
only see a limit number of spaces away.  This precise number is determined by
the ```vision_radius``` value in the config file.

Technically, the whole array of what you can see is given via the 
```sensors.vision_array``` object.  But using this can be unweildy
because you have to figure out your location in that array and calculate
offsets.  

```

sensors.vision(0,0) 
# =>  your agent's own location


sensors.vision(-1,0)
# => one above

sensors.vision(1,0)
# => one below 

sensors.vision(0,-1)
# => one left

sensors.vision(1,0)
# => one below 
```

#### Other sensors

```
:vision_array #A raw array of your vision
:vision_radius #The size of your vision radius
:has_box #Is true if the agent is holding a box
:foe_teams #A list of foe teams
:friendly_spawn_dir #A 2-d unit vector that points to your own spawn
:foe_spawn_dirs #A list of directions, each pointing to a foe's spawn
:agent_id  #A unique ID assigned to each agent
```


## The Grid

An example of a single frame:
```
............................
............................
...1........................
............................
............................
............................
............................
............................
............................
............................
............................
............................
........................2...
............................
```

####Legend:

(space) = an empty square (though above we use periods, for clarity)

o = Team 1 worker

O = Team 1 worker with block

x = Team 2 worker

X = Team 2 worker with block

b = block on the ground

, = block owned by a team

1 = Team 1 spawn point

2 = Team 2 spawn point
