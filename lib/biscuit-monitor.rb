# encoding: utf-8

require 'biscuit-monitor/version'
require 'thor'
require 'net/http'
require 'uri'
require 'multi_json'
require 'ap'

module Biscuit
  module Monitor

    class Monitor
      def initialize(username, password, device_ip)
        @username = username
        @password = password
        @device_ip = device_ip
      end

      def device_uri
        URI.parse("http://#{@username}:#{@password}@#{@device_ip}/cgi-bin/webmain.cgi?act=act_wimax_status&param=WIMAX_LINK_STATUS,WIMAX_DEVICE_STATUS")
      end

      def poll
        begin
          ap parse(scrub_response(Net::HTTP.get(device_uri)))
          sleep 5
        end until false
      end

      def parse(document)
        data = {}
        MultiJson.decode(document, symbolize_keys: true).each do |k,v|
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
                    elsif v.class == Array
                      v.each do |a|
                        a[1] = if a[1].class == String && /^-?\d+$/ =~ a[1]
                                 Integer(a[1])
                               else
                                 a[1]
                               end
                      end
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

      desc "login", "prompts for username and password"
      def start
        username  = ask("Enter your username:  ") { |q| q.echo = true }
        password  = ask("Enter your password:  ") { |q| q.echo = "*" }
        device_ip = ask("Enter your device ip:  ") { |q| q.echo = "*" }

        Biscuit::Monitor::Monitor.new(username, password, device_ip).poll
      end

    end
  end
end
