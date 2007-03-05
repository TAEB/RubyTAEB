#!/usr/bin/ruby
require 'ai/task/base.rb'

# TODO: check to see if the ground has any food
#       update and check the food-carrying status of our hero

class TaskEatFood < BaseTask
  def safe_food?(food)
    $safe_food.each do |safe|
      return true if food =~ safe
    end
    return false
  end

  def priority()
    return 0 unless $controller.vt.row(23) =~ /(Hungry|Weak|Fainting|Fainted)/
    return 0.8 if $1 == "Hungry"
    return 0.9 if $1 == "Weak"
    return 1
  end

  def run()
    $controller.send("e")

    while 1
      if $controller.vt.row(0) =~ /^You don't have anything to eat\./
        return false
      end

      # handle items on the ground
      if $controller.vt.row(0) =~ /^There (?:is|are) (.+) here; eat (?:it|one)\? \[ynq\] \(n\)/
        if safe_food?($1)
          $controller.send("y")
          return true
        end
        $controller.send("n")
        next
      end

      # handle items in inventory
      $controller.send("?")
      menu = nil
      begin
        menu = Menu.new()
        menu.single_select() do |food|
          safe_food?(food)
        end
      rescue RuntimeError => err
        if err == "I see no menu on the screen."
          # only one stack of food in inv, eat it if it's safe
          if $controller.vt.row(0) =~ /^(.) - (.+)--More-- *$/
            $controller.send(" ")
            if safe_food?($2)
              $controller.send($1)
              return true
            else
              $controller.send("\n")
              return false
            end
          end
          raise "E001: Did not match the expected eat-command regex"
        elsif err == "I didn't select an item from the single-select menu."
          menu.execute()
          return false
        end
      end
    end
  end
end

