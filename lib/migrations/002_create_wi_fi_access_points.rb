# encoding: utf-8

Sequel.migration do
  change do
    create_table :wi_fi_access_points do
      primary_key :id
      String :ssid
      String :ssid_name
      Integer :rssi # -56
      String :bssid # "00:00:02:26:27:93"
      String :scanned_on
    end
  end
end
