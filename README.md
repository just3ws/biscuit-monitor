# Biscuit::Monitor

Command-line utility that monitors your CLEAR Spot 4G+ Personal Hotspot and prints out the connection strength.

Tested on Ruby 1.9.3-p194 running on OS X Lion.

My device is running the official CLEAR Spot 4G+ Personal Hotspot software.

Device Manufacturer : INFOMARK
Software Version :  2.0.0.0 [R2207 (Dec 7 2010 14:13:20)]
Firmware Version :  1.9.9.4
Hardware Version :  R05
WiMAX API Version : 1.2

## Installation

Add this line to your application's Gemfile:

    gem 'biscuit-monitor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install biscuit-monitor

## Usage

biscuit-monitor -d 192.168.1.1

Execute the gem passing in the IP address of your CLEAR Spot 4G+ Personal Hotspot modem.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Notes

- cinr

  Carrier to Interference-plus-Noise Ratio (CINR)

- rssi

  Received signal strength indication

## Reference

http://www.clear.com/support/faq/connection-issues/connectionsignal/how-do-i-find-my-cinr-score-from-my-clear-spot-device

From the CLEAR Spot 4G+ Personal Hotspot website

CINR

CINR stands for Carrier to Interference-plus-Noise Ratio (CINR), expressed in decibels (dBs). CINR is a measurement of signal effectiveness. We use the CINR score to tell us the signal quality received by the modem.

The higher the number the better signal quality you are receiving. You need at minimum a CINR of 8 or greater to receive consistent service. A CINR score of 18 or higher is considered excellent signal quality.

RSSI

RSSI stands for Received signal strength indicator RSSI is a measurement of the power present in a received radio signal. We use RSSI score to tell us the strength of signal your CLEAR Spot 4G+ Personal Hotspot is receiving.

A RSSI score of -100dBm reflects poor signal strength, a score of -50dBm is an excellent RSSI score and reflects a strong signal.

## Disclaimer

I created this utility for my own use but if you find it useful then that's great! I am NOT in any way affiliated or a representative for CLEAR. I just like the device and was tired of having to refresh the admin page in the browser.

Use this at your own risk. I take no responsibility for burning up your device or killing your battery or anything else for that matter.
