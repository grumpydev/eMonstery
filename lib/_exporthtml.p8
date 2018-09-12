pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
printh("1")
cd("/carts/emonstery")
printh("2")
load("emonstery.p8")
printh("3") 
cd("/carts/emonstery/docs")
printh("4")
printh("exporting as html")
export("emonstery.html")

