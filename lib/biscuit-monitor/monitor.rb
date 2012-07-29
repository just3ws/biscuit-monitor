# encoding: utf-8

module Biscuit
  module Monitor
    class Monitor
      def initialize(device_ip, polling_frequency_in_seconds)
        @device_ip = device_ip
        @polling_frequency_in_seconds = polling_frequency_in_seconds
      end

      def poll
        catch :ctrl_c do
          until false
            begin

              ss = SignalStrength.new(@device_ip)

              message = ''
              message << ss.cinr
              message << ' '
              message << ss.rssi

              write message

              Thread.new {
                DB_CONN[:wi_max_statuses].insert(response)
                LOGGER.debug(response)
              }

            rescue Errno::EHOSTUNREACH => err

              write "Cannot find the biscuit. Check your connection. Tail #{LOG_FILE} for details."
              LOGGER.error(err.inspect)

            rescue StandardError => err

              write "There was an error talking to your biscuit. Tail #{LOG_FILE} for details."
              LOGGER.error(err.inspect)

            ensure

              sleep @polling_frequency_in_seconds # TODO when error increase length of time until next check to avoid spamming error log

            end
          end
        end
      end

      private

      def clear_last_message
        (@last_message || '').length.times { print "\b" }
      end

      def write(message)
        clear_last_message
        print message
        @last_message = message
      end
    end
  end
end

