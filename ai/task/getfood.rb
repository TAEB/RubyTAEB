#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskGetFood < BaseTask
  def safe_food?(food)
    $safe_food.each do |safe|
      return true if food =~ safe
    end
    return false
  end

  def priority()
    adjacent_fightable?() ? 1 : 0
  end

  def run()
    $controller.send(",")
    begin
      menu = Menu.new()
    rescue RuntimeError => err
      if err == "I see no menu on the screen."

      else
        throw err
      end

  end
end


