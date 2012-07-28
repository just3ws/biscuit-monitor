# encoding: utf-8

module Biscuit
  module Monitor

    require 'biscuit-monitor/version'
    require 'colorize'
    require 'etc'
    require 'logger'
    require 'multi_json'
    require 'net/http'
    require 'sequel'
    require 'sqlite3'
    require 'thor'
    require 'uri'

    HOME_DIR = Etc.getpwuid.dir
    biscuit_monitor_root_dir = "#{HOME_DIR}/.biscuit-monitor"
    Dir.mkdir(biscuit_monitor_root_dir) unless File.directory?(biscuit_monitor_root_dir)
    biscuit_monitor_log_dir =  "#{biscuit_monitor_root_dir}/log"
    Dir.mkdir(biscuit_monitor_log_dir) unless File.directory?(biscuit_monitor_log_dir)

    LOGGER = Logger.new("#{biscuit_monitor_log_dir}/biscuit-monitor.log", 10, 1024000)

    DB = Sequel.sqlite("#{biscuit_monitor_root_dir}/biscuit_monitor.db", loggers: [LOGGER])

    Sequel.extension :migration
    Sequel::Migrator.apply(DB, File.expand_path(File.dirname(__FILE__)) + '/migrations')

    SCAN_WIFI_COMMAND = %x[/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s]

    trap('SIGINT') { throw :ctrl_c }

    class CLI < Thor
      default_task :start

      desc 'start', 'Start monitoring your biscuit.'
      method_option :device_ip, default: '192.168.1.1', aliases: '-d'
      method_option :polling_frequency_in_seconds, default: 3, aliases: '-f'
      def start
        Biscuit::Monitor::Monitor.new(options[:device_ip], Integer(options[:polling_frequency_in_seconds])).poll
      end
    end

    class Monitor
      def initialize(device_ip, polling_frequency_in_seconds)
        @device_ip = device_ip
        @polling_frequency_in_seconds = polling_frequency_in_seconds
      end

      def device_uri
        URI.parse("http://#@device_ip/cgi-bin/webmain.cgi?act=act_wimax_status&param=WIMAX_LINK_STATUS,WIMAX_DEVICE_STATUS")
        # TODO get the battery status
        # URI.parse("http://#{@device_ip}/cgi-bin/webmain.cgi?act_battery_status&TYPE=BISCUIT&param=BATTERY_STATUS")
      end

      def clear_last_message
        (@last_message || '').length.times { print "\b" }
      end

      def cinr_foreground_color(cinr)
        case
        when cinr > 24 then
          :green
        when (13..24).include?(cinr) then
          :light_green
        when (8..12).include?(cinr) then
          :yellow
        when (3..7).include?(cinr) then
          :light_red
        when cinr < 3 then
          :red
        else
          :white
        end
      end

      def rssi_foreground_color (rssi)
        case
        when rssi > -50 then
          :green
        when rssi < -100 then
          :red
        else
          :yellow
        end
      end

      def poll
        catch :ctrl_c do
          until false
            begin
              response = parse(parse_javascript_to_json(Net::HTTP.get(device_uri)))[:data]

              cinr = Integer(response[:cinr])
              rssi = Integer(response[:rssi])

              message = "CINR: #{cinr}dBs".colorize(cinr_foreground_color(cinr))
              message << ' '.uncolorize
              message << "RSSI: #{rssi}dBs".colorize(rssi_foreground_color(rssi))

              write message

              Thread.new {
                DB[:wi_max_statuses].insert(response)
                LOGGER.debug(response)
              }

            rescue Errno::EHOSTUNREACH => err

              write 'Cannot find the biscuit. Check your connection.'
              LOGGER.error(err.inspect)

            rescue StandardError => err

              write 'There was an error checking your biscuit. See the logfile for details.'
              LOGGER.error(err.inspect)

            ensure

              sleep @polling_frequency_in_seconds # TODO when error increase length of time until next check to avoid spamming error log

            end
          end
        end
      end

      def write(message)
        clear_last_message
        print message
        @last_message = message
      end

      def parse(document)
        data = {}
        hash = MultiJson.decode(document, symbolize_keys: true)
        hash.delete(:list)
        hash.each do |k, v|
          data[k] = if v.class == String && /^-?\d+$/ =~ v
                      Integer(v)
                    elsif v.class == Hash
                      idata = {}
                      v.each do |ik, iv|
                        idata[ik] = if iv.class == String && /^-?\d+$/ =~ iv
                                      Integer(iv)
                                    else
                                      iv
                                    end
                      end
                      idata
                    else
                      v
                    end
        end
        data
      end

      def parse_javascript_to_json(document)
        document = document.downcase.split.join
        document.gsub!(/'/, '"')
        document.gsub!(/:(\d*),/, ':"\1",')
        document.gsub!(/(\w*):"/, '"\1":"')
        document.gsub!(/(\w*):{/, '"\1": {')
        document.gsub!(/(\w*):\[/, '"\1": [')
        document.gsub!(/":"/, '": "')
        document.gsub!(/,/, ', ')
      end
    end
  end
end
