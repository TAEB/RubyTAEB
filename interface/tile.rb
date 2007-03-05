#!/usr/bin/ruby

class Tile
  attr_reader :scenery, :items, :monster
  def initialize()
    @scenery = nil
    @items = nil
    @monster = nil
  end

  def scenery?
    case scenery
    when '.', ',', ']', '-', '|', '#', '}', '{', '<', '>', '^'
      true
    else
      false
    end
  end

  def is_walkable?
    case scenery
    when ".", "#", ",", "]", ">", "<", "{", "_", "\\", "^"
      return true
    end
    if
      case items[0]
      when "!", "?", "+", "=", '"', "/", "(", ")", "[", "$", "`", "%", "*"
        true
    end
    return false
  end

  def walk_penalty
    case tile
    when "^"
      1000
    when ".", "#", ",", "]", ">", "<", "{", "_", "\\", "^"
      1
    when "!", "?", "+", "=", '"', "/", "(", ")", "[", "$", "`", "%", "*"
      1
    end
  end

end

