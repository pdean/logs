import threading
import time
from gps import *
from datetime import datetime

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
       except StopIteration:
            pass

if __name__ == '__main__':

   gpsp = GpsPoller()
   gpsp.start()
   while 1:
       time.sleep(.1)
       report = gpsp.get_current_value()
       if report['class'] == 'TPV':
           print(datetime.now().strftime('%H:%M:%S'))
           print(report.time.split('T')[1], report.lat, report.lon)
           print()

