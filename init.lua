print("set up wifi mode e configuro in e out")
--utilizzato GPIO2 per comandare il rele della sirena
gpio.mode(4,gpio.OUTPUT)
--Utilizzato GPIO0 come input 
gpio.mode(3,gpio.INPUT,gpio.PULLUP)
gpio.write(4,gpio.LOW)

timeOn=0
timeOff=0
local StrUltimoAllarme='' 

wifi.setmode(wifi.SOFTAP)
local cfg
cfg = {
   ip = "192.168.4.1",
   netmask = "255.255.255.0",
   gateway = "192.168.4.1"
}
wifi.ap.setip(cfg)

cfg = {
   ssid = "ESP_Nonno",
   pwd = "12345678"
}
wifi.ap.config(cfg)

print("\r\n********************")
print("ESP IP:\r\n", wifi.ap.getip())
print("Heap:\r\n", node.heap())
print("********************")

cfg = nil

-- COMPILE LUA FILES

-- START SERVER
collectgarbage()

--wifi.sta.config("SSID","PassWord")
 --here SSID and PassWord should be modified according your wireless router
--wifi.sta.connect()


allarmOn=0

tmr.alarm(0,500,1,function()
--print("\r\n**allarmOn:",allarmOn)
if (gpio.read(3) == gpio.LOW and allarmOn == 0) then 
    allarmOn=1
	timeOn=tmr.now()
    gpio.write(4,gpio.HIGH)   
end 
if allarmOn == 1 then
	disattivaSirena()
end
end)


function disattivaSirena()
    --print(tmr.now())
	--print (gpio.read(4))
	--300000000 = 5 minuti
	if(tmr.now()-timeOn> 300000000 and allarmOn == 1) then 
		allarmOn = 2
		timeOff=tmr.now()
		gpio.write(4,gpio.LOW)
	end
end

local srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
    print(payload) 
	print("\r\n**allarmOn:",allarmOn)
	print("\r\n**timeOn:",timeOn)
	print("\r\n**timeOff:",timeOff)
	print("\r\n** rele su gpio.read(4):",gpio.read(4))
	print("\r\n** contatto su gpio.read(4):",gpio.read(3))
    conn:send("<h1> Allarme giardino<BR>Server is working!<BR>allarmOn=")
	conn:send(allarmOn)
	conn:send("<BR>Ultimo Allarme minuti passati=")
	if (allarmOn >0) then
		conn:send((tmr.now()-timeOn)/60000000)
		conn:send("<BR>Ha suonato per Minuti:")
		conn:send((timeOff-timeOn)/60000000)
	else 
		conn:send("Mai suonato")
	end
	conn:send("</h1>")
    conn:close()
	end) 
end)