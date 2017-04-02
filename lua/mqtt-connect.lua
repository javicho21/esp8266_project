--NodeMCU:$6$XpTr87cajaFXLmgs$L2G0ijLrz8p01R6kAK0vdFe80hw7KY4wNT7IWNv+cbBRWOIfwBV$
--nodered:$6$taMkkO3rslH+CBAg$jGGtuN/tdppE0T/xXLUUOpXZypJyEvIF+ZmNoTvCBN48y77WC08$
------------------------------------------
--- Set Variables ---
------------------------------------------
--[[
MQTT_BROKER = "192.168.1.190"
MQTT_BROKER_PORT = 1883
MQTT_BROKER_SECURE = 0

MQTT_PUBLISH_TOPIC = "my_topic"
MQTT_PUBLISH_TOPIC_QoS = 0
MQTT_PUBLISH_TOPIC_RETAIN = 0
MQTT_PUBLISH_MESSAGE = "Hello MQTT"

MQTT_SUBSCRIBE_TOPIC = "my_topic"
MQTT_SUBSCRIBE_TOPIC_QoS = 0

MQTT_CLIENT_ID = "wind2"
MQTT_CLIENT_USER = "jvazquez"
MQTT_CLIENT_PASSWORD = "password"
MQTT_CLIENT_KEEPALIVE_TIME = 120
--]]
MQTT_BROKER = "172.24.1.1"
MQTT_BROKER_PORT = 1883
MQTT_BROKER_SECURE = 0

MQTT_PUBLISH_TOPIC = "my_topic"
MQTT_PUBLISH_TOPIC_QoS = 0
MQTT_PUBLISH_TOPIC_RETAIN = 0
MQTT_PUBLISH_MESSAGE = "Hello MQTT"

MQTT_SUBSCRIBE_TOPIC = "my_topic"
MQTT_SUBSCRIBE_TOPIC_QoS = 0

MQTT_CLIENT_ID = "NodeMCU"
MQTT_CLIENT_USER = "NodeMCU"
MQTT_CLIENT_PASSWORD = "qzwxecrv"
MQTT_CLIENT_KEEPALIVE_TIME = 120


-- get station's mac address to use as mqtt topic name
nodemac = wifi.sta.getmac()
topic = ("/nodes/"..nodemac)
-- other variables
send_interval = 5 --in seconds
reset_interval = 30 --in seconds
------------------------------------------

value_table = {}

reset_timer = tmr.create()
reset_timer:register(reset_interval*1000, tmr.ALARM_SINGLE, 
    function (t)           
        print(tmr.now(),"reset timer activated! Resetting!"); 
        node.restart()
    end)
reset_timer:start()


--- Initiate MQTT Client ---
m = mqtt.Client(MQTT_CLIENT_ID, MQTT_CLIENT_KEEPALIVE_TIME, MQTT_CLIENT_USER, MQTT_CLIENT_PASSWORD)

--- Callback for mqtt events ---
m:on("connect", 
    function(client) 
        print("mqtt connected to broker")
    end)
m:on("offline", 
    function(client) 
        print ("mqtt client is offline, stop reading UART.") 
        mytimer:unregister()
        uart.on("data") -- unregister callback function
    end)

-- on publish message receive event
m:on("message", function(client, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
end)

-- for TLS: m:connect("192.168.11.118", secure-port, 1)
m:connect(MQTT_BROKER, MQTT_BROKER_PORT, MQTT_BROKER_SECURE,
    function(client)
        print (tmr.now(),"mqtt connected, start reading UART...") 
        listen_to_uart()
        local mytimer = tmr.create()
        -- oo calling
        mytimer:register(send_interval*1000, tmr.ALARM_AUTO, 
            function (t)
                print(tmr.now(),"timer activated, sending data to mqtt broker..."); 
                send_to_mqtt()
            end)
        mytimer:start()
        
    end, 
    function(client, reason) print("mqtt conn failed, reason: "..reason) end)

-- subscribe topic with qos = 0
-- m:subscribe("/nodes",0, function(client) print("subscribe success") end)


function send_to_mqtt()
    print("INFO: publishing available data...")
    for sensor_id, value in pairs(value_table) do
        --print ("sendor_id = ",sensor_id, "value = ",value)
        payload = (sensor_id..","..value..",")
        print (payload)
        m:publish(topic,payload,0,0, function(client) print("sent") end)
    end
    
    print("INFO: clearing table...")
    value_table = {}
end

function listen_to_uart()
    
    --create callback for uart events
    uart.on("data", "\r",
        function(data)
            if data ~= "end\r" then
                print("INFO: received from uart: {", data,"}")
                sensor_id, value = data:match("([%d]+),(.?[%d%.]*)")
                print ("INFO: adding to table: sendor_id = ",sensor_id, "value = ",value)
                value_table[sensor_id] = value
                
            end
        end, 0)
    
end
