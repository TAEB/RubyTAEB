#!/usr/bin/ruby

class Hero
  attr_accessor :prayertimeoutmin, :prayertimeoutmax

  def initialize()
    @x = @y = 0
    @prayertimeoutmin = 300
    @prayertimeoutmax = 500
  end

  def x()
    $controller.vt.x
  end

  def y()
    $controller.vt.y
  end
end

