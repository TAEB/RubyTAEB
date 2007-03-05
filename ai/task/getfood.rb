#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskGetFood < BaseTask
  def priority()
    0
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


