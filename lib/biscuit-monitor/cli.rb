# encoding: utf-8

module Biscuit
  module Monitor

    require 'thor'

    class CLI < Thor
      default_task :monitor

      desc 'monitor', 'Start monitoring your biscuit.'
      method_option :device_ip, default: '192.168.1.1', aliases: '-d'
      method_option :polling_frequency_in_seconds, default: 3, aliases: '-f'

      def monitor
        Biscuit::Monitor::Poller.new(options[:device_ip], Integer(options[:polling_frequency_in_seconds])).poll
      end
    end
  end
end
