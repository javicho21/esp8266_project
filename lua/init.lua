
tmr.delay(500)

print ("Checking for abort request in 500ms!")
abort_pin = 3 -- GPIO0 pin

if (gpio.read(abort_pin) ~= 1) then 
    print("\n Startup abort requested! Waiting for instructions!")
    local mytimer = tmr.create()
    mytimer:register(5000, tmr.ALARM_AUTO, function (t) print("Waiting for instructions!") end)
    mytimer:start()
else
    print("\n Proceeding with startup!")

    print("\n Preparing ADC...")
    if adc.force_init_mode(adc.INIT_ADC) then
    node.restart()
    end
    
	print("\n Running wifi-config.lua!")
    dofile("wifi-config.lua")
end
    


