# encoding: utf-8

module Biscuit
  module Monitor

    %w< multi_json net/http uri >.each {|dep| require dep }

    class SignalStrength

      def initialize(device_ip)
        @device_ip = device_ip
        @response = parse(parse_javascript_to_json(Net::HTTP.get(device_uri)))[:data]
      end

      def cinr
        Cinr.new(@response[:cinr]).message
      end

      def rssi
        Rssi.new(@response[:rssi]).message
      end

      private

      def device_uri
        URI.parse("http://#@device_ip/cgi-bin/webmain.cgi?act=act_wimax_status&param=WIMAX_LINK_STATUS,WIMAX_DEVICE_STATUS")
        # TODO get the battery status
        # URI.parse("http://#{@device_ip}/cgi-bin/webmain.cgi?act_battery_status&TYPE=BISCUIT&param=BATTERY_STATUS")
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
