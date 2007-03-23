#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskPrayForFood < BaseTask
  def should_run?()
    return false unless $controller.vt.row(23) =~ /(Weak|Fainting|Fainted)/
    return true
  end

  def run()
    $controller.send("#pray\n")
    $hero.prayertimeoutmin += 50
    $hero.prayertimeoutmax += 1000
  end
end
