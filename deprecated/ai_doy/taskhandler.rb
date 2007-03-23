#!/usr/bin/ruby
require 'ai/prioritizedprog.rb'
$:.push('ai/goal/')
require 'descend.rb'
require 'explore.rb'
require 'fallback.rb'
require 'handlemonster.rb'
require 'survive.rb'
require 'updatemap.rb'

class TaskHandler
  def initialize()
    @goals = [
      PrioritizedProg.new(99999, GoalUpdateMap.new()    ), # takes 0 time
      PrioritizedProg.new(10000, GoalSurvive.new()      ),
      PrioritizedProg.new( 1000, GoalHandleMonster.new()),
      PrioritizedProg.new(  100, GoalExplore.new()      ),
      PrioritizedProg.new(   10, GoalDescend.new()      ),
      PrioritizedProg.new(    1, GoalFallback.new()     ),
    ]
  end

  # This runs the task with the highest priority. If that task's run returns a
  # false value, run the next-highest-priority task, and so on.
  # Warning: some tasks depend on having should_run? called each tick, so you
  # can't stop processing early (a possible optimization) unless should_run?
  # is separated from update
  def next_task()
    tasks = []
    @goals.each do |goal|
      tasks += goal.prog.tasks().map {|task|
          PrioritizedProg.new(task.priority * goal.priority, task.prog) }
    end
    tasks.sort {|a,b| b.priority <=> a.priority}.each do |task_array|
      next unless task_array.prog.should_run?
      debug("Running #{task_array.prog.class.to_s} which has priority #{task_array.priority}")
      result = task_array.prog.run()
      clear_screen()
      break if result
    end
    new_goals = []
    @goals.each do |goal|
      new_goals << goal unless goal.prog.accomplished?()
      # this needs a way to create the new priorities intelligently...
      new_goals += goal.prog.new_goals()
    end
    @goals = new_goals
    # HACK: move this into our turn handler whenever it gets implemented
    $hero.prayertimeoutmin -= 1
    $hero.prayertimeoutmax -= 1
  end

  def clear_screen()
    if $controller.vt.row(0) =~ /Things that are here: *$/ or
       $controller.vt.row(2) =~ /Things that are here: *$/
      debug("Things that are here menu")
      $controller.send(" ")
      clear_screen()
    end

    if $controller.vt.row(0) =~ /^Do you want your possessions identified\?/ or
       $controller.vt.row(0) =~ /^Do you want to see what you had when you died\?/
      debug("Oh no! We died!")
      $controller.send("y")
      while 1 # let the Disconnect exception break the loop
        $controller.send(" ")
        sleep 1
      end
    end

    if $controller.vt.to_s =~ /--More--/
         debug("I see a --More--!")
         $controller.send(" ")
         clear_screen()
    end

    if $controller.vt.to_s =~ /Call a/
      debug("I see a: Call a ...")
      $controller.send("\n")
      clear_screen()
    end

    if $controller.vt.to_s =~ /the Were\w+/
      debug("I'm a werecritter! Praying..")
      $controller.send("#pray\n")
      clear_screen()
    end

    if $controller.vt.to_s =~ /\? \[[ynq]+\] \(.\)/
        debug("I see a prompt!")
        $controller.send(" ")
    end
  end
end

