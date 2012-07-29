# encoding: utf-8

module Biscuit
  module Monitor

    %w< colorize logger multi_json net/http uri >.each {|dep| require dep }

    class Monitor
      def initialize(device_ip, polling_frequency_in_seconds)
        @device_ip = device_ip
        @polling_frequency_in_seconds = polling_frequency_in_seconds
      end

      def poll
        catch :ctrl_c do
          until false
            begin
              response = parse(parse_javascript_to_json(Net::HTTP.get(device_uri)))[:data]

              cinr = Cinr.new(response[:cinr])
              rssi = Rssi.new(response[:rssi])

              message = cinr.message
              message << ' '.uncolorize
              message << rssi.message

              write message

              Thread.new {
                DB_CONN[:wi_max_statuses].insert(response)
                LOGGER.debug(response)
              }

            rescue Errno::EHOSTUNREACH => err

              write "Cannot find the biscuit. Check your connection. Tail #{LOG_FILE} for details."
              LOGGER.error(err.inspect)

            rescue StandardError => err

              write "There was an error checking your biscuit. Tail #{LOG_FILE} for details."
              LOGGER.error(err.inspect)

            ensure

              sleep @polling_frequency_in_seconds # TODO when error increase length of time until next check to avoid spamming error log

            end
          end
        end
      end

      private

      def device_uri
        URI.parse("http://#@device_ip/cgi-bin/webmain.cgi?act=act_wimax_status&param=WIMAX_LINK_STATUS,WIMAX_DEVICE_STATUS")
        # TODO get the battery status
        # URI.parse("http://#{@device_ip}/cgi-bin/webmain.cgi?act_battery_status&TYPE=BISCUIT&param=BATTERY_STATUS")
      end

      def clear_last_message
        (@last_message || '').length.times { print "\b" }
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

