print("set up wifi mode e configuro in e out")
--utilizzato per comandare il rele della sirena
gpio.mode(4,gpio.OUTPUT)
--Utilizzato come input 
gpio.mode(3,gpio.INPUT,gpio.PULLUP)
time=0

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
print("\r\n**allarmOn:",allarmOn)
if gpio.read(3)== gpio.LOW then 
    allarmOn=1 
    gpio.write(4,gpio.HIGH)
else 
    allarmOn=0 
    gpio.write(4,gpio.LOW) 
end 
end)

local srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
    print(payload) 
    conn:send("<h1> ESP8266<BR>Server is working!</h1><BR>allarmOn=")
	conn:send(allarmOn)
    conn:close()
	end) 
end)