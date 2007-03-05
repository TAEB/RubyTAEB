#!/usr/bin/ruby

class BaseTask
  def initialize()
  end

  def priority()
    raise "You need to override BaseTask.priority"
  end

  def run()
    raise "You need to override BaseTask.run"
  end
end

