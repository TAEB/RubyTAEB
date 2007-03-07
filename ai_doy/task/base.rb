#!/usr/bin/ruby

class BaseTask
  def should_run?()
    raise "You need to override BaseTask.should_run?"
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
    $map.each_direction do |dx, dy|
      next if $hero.y+dy < 1 or $hero.y+dy > 22
      if $map.at_delta(dx, dy).scenery == ']'
        return $map.move_with_delta(dx, dy)
      end
    end
    nil
  end

  def adjacent_fightable_direction()
    $map.each_direction do |dx, dy|
      next if $hero.y+dy < 1 or $hero.y+dy > 22
      if $map.at_delta(dx, dy).monster?
        return $map.move_with_delta(dx, dy)
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

  def goal?()
    false
  end
end

