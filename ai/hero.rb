#!/usr/bin/ruby

class Hero
  def initialize()
    @x = @y = 0
  end

  def x()
    $controller.vt.x
  end

  def y()
    $controller.vt.y
  end
end

