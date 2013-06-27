#!/usr/bin/ruby
require 'basestyle.rb'

class StyleGeneric < BaseStyle
  def initialize()
    @goals = [
               SupergoalExploreFirstLevels,
               SupergoalExploreMinetown,
               SupergoalCompleteSokoban,
               SupergoalGetMR,
               SupergoalFindCoalignedAltar,
               SupergoalMakeHolyWater,
               SupergoalGetLuckstone,
               SupergoalMaxLuck,
               SupergoalDigUntilCastle,
               SupergoalGetCastleWand,
               SupergoalCompleteQuest,
               SupergoalClearValley,
               SupergoalFindVS,
               SupergoalGetCandelabrum,
               SupergoalGetBook,
               SupergoalGetAmulet,
               SupergoalGetToEarth,
               SupergoalDoPlanes
             ]

    @transform_into = nil
  end
end


