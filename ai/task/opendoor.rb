#!/usr/bin/ruby

class TaskOpenDoor
  def initialize()
  end

  def closable?(tile)
    case tile
    when ","
      true
    else
      false
    end
  end

  def openable?(tile)
    case tile
    when "]"
      true
    else
      false
    end
  end

  def run()
    move = next_move($hero.x, $hero.y)
    if move
      $stderr.puts "Closing/kicking toward #{move} from #{$hero.x}, #{$hero.y}"
      $controller.send(move)
      return true
    end
    return false
  end

  def move_with_delta(dx, dy)
    case dx
    when -1
      case dy
      when -1
        'y'
      when 0
        'h'
      when 1
        'b'
      else
        throw "unacceptable dy: #{dy}"
      end
    when 0
      case dy
      when -1
        'k'
      when 1
        'j'
      else
        throw "unacceptable dy: #{dy}"
      end
    when 1
      case dy
      when -1
        'u'
      when 0
        'l'
      when 1
        'n'
      else
        throw "unacceptable dy: #{dy}"
      end
    else
      throw "unacceptable dx: #{dx}"
    end
  end

  def each_adjacent()
    for dx in [-1, 0, 1]
      for dy in [-1, 0, 1]
        yield dx, dy unless dx == 0 and dy == 0
      end
    end
  end

  def next_move(x, y)
    each_adjacent do |dx, dy|
      if openable?($controller.at(x+dx,y+dy))
        return 4.chr + move_with_delta(dx, dy)
      elsif closable?($controller.at(x+dx,y+dy))
        return "c" + move_with_delta(dx, dy)
      end
    end

    return nil
  end
end

