# encoding: utf-8

require 'active_record'
require 'biscuit-monitor/version'
require 'colorize'
require 'logger'
require 'multi_json'
require 'net/http'
require 'sqlite3'
require 'thor'
require 'uri'

module Biscuit
  module Monitor
    trap("SIGINT") { throw :ctrl_c }

    class CLI < Thor
      default_task :start

      desc "start", "Start monitoring your biscuit."
      method_option :device_ip, :default => "192.168.1.1", :aliases => "-d"
      def start
        Biscuit::Monitor::Monitor.new(options[:device_ip]).poll
      end
    end

    class Monitor
      def initialize(device_ip)
        @logger = Logger.new('biscuit-monitor.log', 10, 1024000)
        @device_ip = device_ip
        @seconds = 3
      end

      def device_uri
        URI.parse("http://#{@device_ip}/cgi-bin/webmain.cgi?act=act_wimax_status&param=WIMAX_LINK_STATUS,WIMAX_DEVICE_STATUS")
        # TODO get the battery status
        # URI.parse("http://#{@device_ip}/cgi-bin/webmain.cgi?act_battery_status&TYPE=BISCUIT&param=BATTERY_STATUS")
      end

      def clear_last_message
        (@last_message || "").length.times { print "\b" }
      end

      def cinr_foreground_color(cinr)
        case
        when cinr > 24 then :green
        when (13..24).include?(cinr) then :light_green
        when (8..12).include?(cinr) then :yellow
        when (3..7).include?(cinr) then :light_red
        when cinr < 3 then :red
        end
      end

      def rssi_foreground_color (rssi)
        case
        when rssi > -50 then :green
        when rssi < -100 then :red
        else :yellow
        end
      end

      def poll
        catch :ctrl_c do
          begin
            response = parse(scrub_response(Net::HTTP.get(device_uri)))

            cinr = Integer(response[:data][:cinr])
            rssi = Integer(response[:data][:rssi])

            message = "CINR: #{cinr}dBs".colorize(cinr_foreground_color(cinr))
            message << " ".uncolorize
            message << "RSSI: #{rssi}dBs".colorize(rssi_foreground_color(rssi))

            write message
            @logger.debug(response)
          rescue Errno::EHOSTUNREACH => err
            write "Cannot find the biscuit. Check your connection."
            @logger.error(err.inspect)
          rescue StandardError => err
            write "There was an error checking your biscuit. See the logfile for details."
            @logger.error(err.inspect)
          ensure
            sleep @seconds  # TODO when error increase length of time until next check to avoid spamming error log
          end until false
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
        hash.each do |k,v|
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

      def scrub_response(document)
        document = document.split.join
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
