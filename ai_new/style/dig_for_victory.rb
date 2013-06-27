#!/usr/bin/ruby
require 'basestyle.rb'

class StyleDigForVictory < BaseStyle
  def initialize()
    @goals = [
               SupergoalFindPickaxe,
               SupergoalDigUntilCastle,
               SupergoalGetCastleWand,
             ]

    # after we complete all of our goals, become some generic style for
    # handling the rest of the game
    @transform_into = StyleGeneric
  end
end

