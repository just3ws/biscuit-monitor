# encoding: utf-8

module Biscuit
  module Monitor

    require 'nokogiri-plist'

    class AccessPointScanner

      SCAN_ACCESS_POINTS = %x[/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --scan --xml]

      attr_reader :found_access_points, :scanned_on

      def exec
        @scanned_on = Time.now.utc

        @found_access_points = raw_found_access_points.map do |access_point|
          { ssid_name: access_point["SSID_STR"], bssid: access_point["BSSID"], rssi: access_point["RSSI"], scanned_on: @scanned_on }
        end
      end

      def raw_found_access_points
        @raw_found_access_points ||= Nokogiri::PList(SCAN_ACCESS_POINTS)
      end

      def scan
        SCAN_ACCESS_POINTS
      end
    end
  end
end
