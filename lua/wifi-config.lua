station_cfg={}
--station_cfg.ssid="DONALDTRUMPFOREMPEROR!!"
--station_cfg.pwd= "Th1nk.Green!954" 
station_cfg.ssid="Pi3-AP"
station_cfg.pwd= "raspberrypi01" 
station_cfg.save=false
--station_cfg.bssid="B8:27:EB:2F:28:78"
station_cfg.auto=true

ip_cfg={}
--ip_cfg.ip = "192.168.1.202"
--ip_cfg.netmask = "255.255.255.0"
--ip_cfg.gateway = "192.168.1.1"

ip_cfg.ip = "172.24.1.20"
ip_cfg.netmask = "255.255.255.0"
ip_cfg.gateway = "172.24.1.255"

wifi.setmode(wifi.STATION)
wifi.setphymode(wifi.PHYMODE_N)
wifi.sta.config(station_cfg)

--print("Current hostname: ",wifi.sta.gethostname())
--print("Current IP: ",wifi.sta.getip())
--print("Current MAC address: ",wifi.sta.getmac())

if ( wifi.sta.getip() ~= ip_cfg) then
    if (wifi.sta.setip(ip_cfg) ~= true) then
        print("Failed to set IP")
        -- retry or reset
    end
end

if (wifi.sta.getmac() == station_mac) then
    if (wifi.sta.setmac(station_mac) ~= true) then
        print("Failed to set MAC")
        -- retry or reset
    end
end

--register callback
wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("STATION_IDLE") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("STATION_WRONG_PASSWORD") end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("STATION_CONNECT_FAIL") end)
wifi.sta.eventMonReg(wifi.STA_GOTIP, 
    function()
        print("STATION_GOT_IP")
		print("\n Running mqtt-connect.lua!")
        dofile("mqtt-connect.lua")
    end)
wifi.sta.eventMonStart()
