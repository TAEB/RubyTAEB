#!/usr/bin/ruby

class BaseTask
  def priority()
    raise "You need to override BaseTask.priority"
  end

  def run()
    move = pick_move
    if move == nil
      return false
    end

    $controller.send(move)
    return true
  end

  def pick_move()
    raise "You need to override BaseTask.pick_move"
  end
end

