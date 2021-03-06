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

  def adjacent_door_direction()
    Map.each_direction do |dx, dy|
      if $map.at_delta(dx, dy).scenery == ']'
        return Map.move_with_delta(dx, dy)
      end
    end
    nil
  end

  def adjacent_fightable_direction()
    Map.each_direction do |dx, dy|
      if $map.at_delta(dx, dy).monster?
        return Map.move_with_delta(dx, dy)
      end
    end
    nil
  end
  def safe_food?(food)
    $safe_foods.each do |safe|
      return true if food =~ safe
    end
    return false
  end
end

