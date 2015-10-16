print("set up wifi mode")
wifi.setmode(wifi.SOFTAP)
local cfg
cfg = {
   ip = "192.168.4.1",
   netmask = "255.255.255.0",
   gateway = "192.168.4.1"
}
wifi.ap.setip(cfg)

cfg = {
   ssid = "ESP",
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
--utilizzato per comandare il rele della sirena
gpio.mode(4,gpio.OUTPUT)
--Utilizzato come input 
gpio.mode(3,gpio.INPUT,gpio.PULLUP)

lighton=0
tmr.alarm(0,1000,1,function()
if gpio.read(3)== gpio.LOW then 
    lighton=1 
    gpio.write(4,gpio.HIGH)
	print("\r\n**lighton:1")
else 
    lighton=0 
    gpio.write(4,gpio.LOW) 
	print("\r\n**lighton:0")
end 
end)
local srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
    print(payload) 
    conn:send("<h1> ESP8266<BR>Server is working!</h1><BR>lighton=")
    conn:close()
	end) 
end)