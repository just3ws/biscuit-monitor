# encoding: utf-8

require 'colorize'

module Biscuit
  module Monitor
    class Rssi
      attr_accessor :level

      def initialize(level)
        @level = Integer(level)
      end

      def message
        "RSSI: #{@level}dBs".colorize(foreground_color)
      end

      def foreground_color
        case
          when @level > -50 then
            :green
          when @level < -100 then
            :red
          else
            :yellow
        end
      end
    end
  end
end
