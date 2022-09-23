# menu with rotary encoder and lcd

# rotary encoder
from gpiozero import RotaryEncoder, Button, LED
from queue import SimpleQueue

rotor = RotaryEncoder(21, 20)
button = Button(16)
eventq = SimpleQueue()

def click():
    eventq.put("CLICK")

def rotup():
    eventq.put("UP")

def rotdown():
    eventq.put("DOWN")

button.when_pressed = click
rotor.when_rotated_clockwise = rotup
rotor.when_rotated_counter_clockwise = rotdown

# leds

blue  = LED(5)
green = LED(6)
red   = LED(13)

def alloff():
    blue.off()
    green.off()
    red.off()

alloff()

# lcd


# charlcd


import board
import digitalio
import adafruit_character_lcd.character_lcd as characterlcd


# Modify this if you have a different sized character LCD
lcd_columns = 20
lcd_rows = 4

# compatible with all versions of RPI as of Jan. 2019
# v1 - v3B+
lcd_rs = digitalio.DigitalInOut(board.D22)
lcd_en = digitalio.DigitalInOut(board.D17)
lcd_d4 = digitalio.DigitalInOut(board.D25)
lcd_d5 = digitalio.DigitalInOut(board.D24)
lcd_d6 = digitalio.DigitalInOut(board.D23)
lcd_d7 = digitalio.DigitalInOut(board.D18)

# Initialise the lcd class
lcd = characterlcd.Character_LCD_Mono(lcd_rs, lcd_en, lcd_d4, lcd_d5, lcd_d6,
                                      lcd_d7, lcd_columns, lcd_rows)


# charlcd with backpack spi

'''
import busio
import adafruit_character_lcd.character_lcd_spi as character_lcd

# Modify this if you have a different sized character LCD
lcd_columns = 20
lcd_rows = 4

# Backpack connection configuration:
clk = board.SCK  # Pin connected to backpack CLK.
data = board.MOSI  # Pin connected to backpack DAT/data.
latch = board.D5  # Pin connected to backpack LAT/latch.

# Initialise SPI bus.
spi = busio.SPI(clk, MOSI=data)

# Initialise the LCD class
latch = digitalio.DigitalInOut(latch)
lcd = character_lcd.Character_LCD_SPI(spi, latch, lcd_columns, lcd_rows)
lcd._shift_register._device.baudrate=10000000

'''

#charlcd with backpack i2c

'''

import board
import busio
import adafruit_character_lcd.character_lcd_i2c as character_lcd

# Modify this if you have a different sized Character LCD
lcd_columns = 20
lcd_rows = 4

# Initialise I2C bus.
#i2c = board.I2C()  # uses board.SCL and board.SDA
i2c = busio.I2C(board.SCL, board.SDA)

# Initialise the lcd class
lcd = character_lcd.Character_LCD_I2C(i2c, lcd_columns, lcd_rows)

'''

# system info menu

from subprocess import Popen, PIPE
from time import sleep
from datetime import datetime
from gpiozero import CPUTemperature

# looking for an active Ethernet or WiFi device
def find_interface():
    find_device = "ip addr show"
    interface_parse = run_cmd(find_device)
    for line in interface_parse.splitlines():
        if "state UP" in line:
            dev_name = line.split(':')[1]
    return dev_name

# find an active IP on the first LIVE network device
def parse_ip(interface):
    find_ip = "ip addr show %s" % interface
    ip_parse = run_cmd(find_ip)
    for line in ip_parse.splitlines():
        if "inet " in line:
            ip = line.split(' ')[5]
            ip = ip.split('/')[0]
    return ip

# run unix shell command, return as ASCII
def run_cmd(cmd):
    p = Popen(cmd, shell=True, stdout=PIPE)
    output = p.communicate()[0]
    return output.decode('ascii')

def info():

    alloff()
    green.blink()

    shift = 0
    lines = lcd_rows
    cols = lcd_columns

    interface = find_interface()
    ip_address = parse_ip(interface)

    lcd.clear()

    while True:
        sleep(1)

        cpu = CPUTemperature()
        output = []
        output.append(datetime.now().strftime('%b %d  %H:%M:%S'))
        output.append('temp=%.1fC' % (float(cpu.temperature)))
        output.append(ip_address)

        line = 0
        items = len(output)
        for item in output[shift:shift+lines]:
            lcd.cursor_position(0,line)
            lcd.message = item.ljust(cols)
            line += 1

        if (not eventq.empty()):
            event = eventq.get()
            if (event == "CLICK"):
                return
            elif event == "UP":
                if shift > 0:
                    shift -= 1
            elif event == "DOWN":
                if shift < items - lines:
                    shift += 1



# location

from gps import *
import threading

class GpsPoller(threading.Thread):

   def __init__(self):
       threading.Thread.__init__(self)
       self.session = gps(mode=WATCH_ENABLE)
       self.current_value = None

   def get_current_value(self):
       return self.current_value

   def run(self):
       try:
            while True:
                self.current_value = self.session.next()
#                time.sleep(0.2) # tune this, you might not get values that quickly
       except StopIteration:
            pass



import psycopg2

sql = """
          select (d1 * cos(b1-b0) + tstart * 1000) as ch,
             (d1 * sin(b1-b0)) as os,
             section,
             code,
             description
      from
        (select section,
                code,
                description,
                tstart,
                tend,
                st_distance(st_startpoint(s.geog::geometry)::geography,
                            st_endpoint(s.geog::geometry)::geography) as d0,
                st_azimuth(st_startpoint(s.geog::geometry)::geography,
                           st_endpoint(s.geog::geometry)::geography) as b0,
                st_distance(st_startpoint(s.geog::geometry)::geography, p.geog) as d1,
                st_azimuth(st_startpoint(s.geog::geometry)::geography, p.geog) as b1
            from tmr2.segs as s,
              (select st_setsrid(
                  st_point(%s,%s),4283)::geography as geog) as p
            where left(code,1) = any(string_to_array('123AKQ', NULL))
            order by s.geog <-> p.geog limit 1) as foo
            """


def location():
    conn = psycopg2.connect("host=localhost dbname=gis user=gis")
    cur = conn.cursor()

    alloff()
    red.blink()

    shift = 0
    lines = lcd_rows
    cols = lcd_columns

    gpsp = GpsPoller() # create the thread
    gpsp.start() # start it up

    while True:
        sleep(.1)
        report = gpsp.get_current_value()
        if report['class'] == 'TPV':
            output = []
            if report.mode == 3:
                output.append(datetime.now().strftime('%H:%M:%S'))
                output.append(report.time.split('T')[1])

                #print(output)

                output.append("Lat %.6f" % (report.lat))
                output.append("Lon %.6f" % (report.lon))

                pos = (report.lon,report.lat)
                cur.execute(sql, pos)
                roadloc = cur.fetchone()
                (ch,os,sec,code,desc) = roadloc
                output.append("%s_%s" % (sec,code))
                output.append("ch %.3f km" % (ch/1000))
                output.append("os %.0f m" %(os))
            else:
                output.append("mode %d" % (report.mode))
                output.append("no fix")
                output.append("")
                output.append("")
                shift = 0



            line = 0
            items = len(output)
            for item in output[shift:shift+lines]:
                lcd.cursor_position(0,line)
                lcd.message = item.ljust(cols)
                line += 1

            if (not eventq.empty()):
                event = eventq.get()
                if (event == "CLICK"):
                    cur.close()
                    conn.close()
                    gpsp.running = False
                    del gpsp
                    return
                elif event == "UP":
                    if shift > 0:
                        shift -= 1
                elif event == "DOWN":
                    if shift < items - lines:
                        shift += 1

# navigation

def navigation():
    lcd.clear()
    lcd.message = "navigation"


    event = eventq.get()
    if event == "CLICK":
        return 

# poweroff

def poweroff():
    lcd.clear()
    lcd.message = "poweroff"


    event = eventq.get()
    if event == "CLICK":
        return 

# main menu

def main():    
    
    menu = ["info","location","navigation","poweroff"]
    action = [info,location,navigation,poweroff]

    alloff()
    blue.blink()


    highlight = 0
    shift = 0
    lines = lcd_rows
    items = len(menu)

    while True:
        lcd.clear()
        line = 0
        for item in menu[shift:shift+lines]:
            if highlight == line:
                prefix = "> "
            else:
                prefix = "  "
            text = prefix + item
            lcd.cursor_position(0,line)
            lcd.message = text
            line += 1

        event = eventq.get()
        if event == "CLICK":
            action[shift+highlight]()

            alloff()
            blue.blink()

        elif event == "UP":
            if highlight > 0:
                highlight -= 1
            else:
                if shift > 0:
                    shift -= 1
        elif event == "DOWN":
            if highlight < lines-1:
                highlight += 1
            else:
                if shift < items - lines:
                    shift += 1


#eventq.put("DOWN")
eventq.put("CLICK")
main()
