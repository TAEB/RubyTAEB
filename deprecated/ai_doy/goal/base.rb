#!/usr/bin/ruby
require 'ai/prog.rb'
require 'ai/prioritizedprog.rb'

class BaseGoal < Prog
  def tasks()
    @pprogs.map do |pprog|
      if pprog.prog.goal?
        pprog.prog.tasks()
      else
        pprog
      end
    end.flatten
  end

  def accomplished?()
    false
  end

  def new_goals()
    []
  end

  def goal?()
    true
  end
end
