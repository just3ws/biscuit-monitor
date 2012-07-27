# encoding: utf-8

Sequel.migration do
  change do
    create_table :wi_max_statuses do
      primary_key :id
      Integer :cf # 2657000
      Integer :cinr # 35
      Integer :rssi # -56
      Integer :tx_power # -11
      String :bsid # "00:00:02:26:27:93"
      String :dev_s # "dataconnected"
      String :dummy09 # "xx"
      String :wimax_device_status # "success"
      String :wimax_link_status # "success"
      String :captured_on
    end
  end
end
