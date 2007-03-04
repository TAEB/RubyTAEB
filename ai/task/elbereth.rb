#!/usr/bin/ruby

class TaskElbereth
  def initialize()
  end

  def low_hp?
    $controller.vt.to_s =~ /HP:?(-?\d+)\((\d+)\)/ or raise "Unable to check HP" + $controller.vt.to_s
    $1.to_i * 2 <= $2.to_i # <= half
  end

  def elberethable?(tile)
    case tile
    when "a".."z", "B".."Z", ":", ";", "~", "'", "&"
      true
    else
      false
    end
  end

  def run()
    if next_move($hero.x, $hero.y)
      $stderr.puts "Elberething!"
      $controller.send("E-  Elbereth\n")
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
    return false unless low_hp?
    each_adjacent do |dx, dy|
      if elberethable?($controller.at(x+dx,y+dy))
        return true
      end
    end

    return false
  end
end


