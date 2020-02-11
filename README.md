# cfb-simluations

This is a script which creates three functions to simulate a college football drive, based on data from 2014-2019.

* sample.play(yards from endzone, down, distance)
  This function pulls a single play from the dataset which matches the yard line, down, and distance that you enter, and returns a result. For example: 
  
 sample.play(75, 1, 10) pulls a random first and ten from your own 25 yard line, and simulates the outcome. When I ran this just now, it returned, for example: "You called a rush which gained 32 yards and picked up a first down."
  
  Then, I can run sample.play(43, 1, 10) to simulate the next play, and so on and so forth until I either score or face a fourth down. 
  When you face a fourth down, you can either go for it (run sample.play() again), punt, or kick a field goal. 
  
 * sim.punt(yardline) returns a punt distance and tells you where the next play will start. For now, there are no returns, fumbles, or blocked punts in the simulation. 
 
 * sim.fg(distance) returns a field goal result: either "MAKE" (in which you score three points and start a new drive!), "MISS" or "BLOCK" (in which case the defense starts a new drive at the yardline of the fieldgoal attempt). For now, there are no returns or turnovers. 
 
 
 #### If you want to replicate your results or simulate a whole game, don't forget to set.seed() beforehand!
 
 
 ### This is a college football version of @statsbylopez's NFL simulator, code for which can be found at his [Github](https://github.com/statsbylopez/StatsSports).
 
 I have plans to make this more robust in terms of granularity of play, but also to stack these simulators to simulate an entire game and then season.
 
Enjoy! 
