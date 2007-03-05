#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskElbereth < BaseTask
  def priority()
    $controller.vt.row(23) =~ /HP:?(\d+)\((\d+)\)/ or raise "Unable to check HP"
    $1.to_i * 2 <= $2.to_i ? 1 : 0
  end

  def pick_move()
    "E-  Elbereth\n"
  end
end

