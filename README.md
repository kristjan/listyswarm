listyswarm
==========

ListySwarm is a 2-d world where you winning means programming from the bottom up.  What set of rules 
when applied to each individual agent will result in the optimal behavior for the entire swarm?

##Writing Your Own Swarm AI

Writing the simplest swarm AI takes only a few minutes to create. 

```
class Agent::RandomAgent < Agent
  def action
    [:north, :south, :east, :west].shuffle.first
  end
end
```

###Available sensors

(TODO: Sum Ting Wong)

##Replay Log Format

The engine shall output a series of files, each ending with increasing numbers that records the game, frame by frame.

Each frame is a literal transcription of the 2-d space.  Subsequent frames are delimeted by a newline.  Any line starting with a ```#``` will be ignored.

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

1 = Team 1 spawn point

2 = Team 2 spawn point
