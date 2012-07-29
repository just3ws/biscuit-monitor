# encoding: utf-8

require 'colorize'

module Biscuit
  module Monitor
    class Cinr
      attr_accessor :level
      def initialize(level)
        @level = Integer(level)
      end

      def message
        "CINR: #{@level}dBs".colorize(foreground_color)
      end

      def foreground_color
        case
        when @level > 24 then
          :green
        when (13..24).include?(@level) then
          :light_green
        when (8..12).include?(@level) then
          :yellow
        when (3..7).include?(@level) then
          :light_red
        when @level < 3 then
          :red
        else
          :white
        end
      end
    end
  end
end
