#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskElbereth < BaseTask
  def should_run?()
    $controller.vt.row(23) =~ /HP:?(\d+)\((\d+)\)/ or raise "Unable to check HP"
    if $1.to_i * 2 > $2.to_i
      return false
    end
    valid_mon = false
    $map.each_adjacent_tile do |tile|
      if tile.monster? and tile.monster != '@' and tile.monster != 'A'
        valid_mon = true
      end
    end
    if not valid_mon
      return false
    end
    $controller.send(": ")
    if not $controller.vt.row(0) =~ /You read: ".*"./
      @wipe = true
    else
      @wipe = false
    end
    if $controller.vt.row(0) =~ /You read: "(?:Elbereth.*){3}/
      return false
    end
    return true
  end

  def pick_move()
    if @wipe
      "E-n  Elbereth\n"
    else
      "E-  Elbereth\n"
    end
  end
end

