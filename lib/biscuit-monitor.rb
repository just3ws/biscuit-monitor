# encoding: utf-8

require 'biscuit-monitor/version'
require 'colorize'
require 'logger'
require 'multi_json'
require 'net/http'
require 'thor'
require 'uri'

module Biscuit
  module Monitor
    trap("SIGINT") {
      @logger.info('No longer monitoring your biscuit.') if @logger
      throw :ctrl_c
    }

    class Monitor
      def initialize(device_ip)
        @logger = Logger.new('biscuit-monitor.log', 10, 1024000)
        @device_ip = device_ip
        @message = ""
        @seconds = 5
      end

      def device_uri
        URI.parse("http://#{@device_ip}/cgi-bin/webmain.cgi?act=act_wimax_status&param=WIMAX_LINK_STATUS,WIMAX_DEVICE_STATUS")
      end

      def clear_last_message
        (@message || "").length.times { print "\b" }
      end

      def poll
        catch :ctrl_c do
          begin
            clear_last_message

            response = parse(scrub_response(Net::HTTP.get(device_uri)))

            signal_strength = Integer(response[:data][:cinr])

            foreground_color = case
                               when signal_strength > 24
                                 :green
                               when (13..24).include?(signal_strength)
                                 :light_green
                               when (8..12).include?(signal_strength)
                                 :yellow
                               when (3..7).include?(signal_strength)
                                 :light_red
                               when signal_strength < 3
                                 :red
                               end

            @message = "Signal Strength: #{signal_strength}".colorize(foreground_color)


            @logger.debug(response)

          rescue Errno::EHOSTUNREACH => err
            @message = "Cannot find the biscuit. Check your connection."
            @logger.error(err.inspect)

          rescue StandardError => err
            @logger.error(err.inspect)
          ensure
            print @message
            sleep @seconds  # TODO when error increase length of time until next check to avoid spamming error log
          end until false

        end
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

    class CLI < Thor
      default_task :start

      desc "start", "Start monitoring your biscuit."
      method_option :device_ip, :default => "192.168.1.1", :aliases => "-d"
      def start

        device_ip = options[:device_ip]
        device_ip ||= ask("Enter your device ip:  ") { |q| q.echo = "*" }

        Biscuit::Monitor::Monitor.new(device_ip).poll
      end
    end
  end
end
