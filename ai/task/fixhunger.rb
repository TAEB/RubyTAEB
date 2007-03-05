#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskFixHunger < BaseTask
  def priority()
    return 0 unless $controller.vt.row(23) =~ /(Weak|Fainting|Fainted)/
    return 0.8 if $1 == "Weak"
    return 1
  end

  def pick_move()
    "#pray\n"
  end
end

