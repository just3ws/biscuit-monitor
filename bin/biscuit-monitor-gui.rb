#!/Applications/Shoes.app/Contents/MacOS/shoes
Shoes.app :title => "Biscuit Monitor", :width => 400, :height => 300 do
  para "What's your login name?"
  @name = edit_line
  para "What's your password?"
  @password = edit_line(:secret => true)
  para "What's the device's IP address?"
  @device_ip = edit_line(:default => "192.168.1.1")

  button("click me") { alert "#{@username} #{@device_ip}" }
end
