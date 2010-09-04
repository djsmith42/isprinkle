import time
from threading import Thread

class iSprinkleWateringService(Thread):
    def run(self):
        print 'Starting watering service'
        self.stopped = 0
        while 1:
            if self.stopped == 1:
                print 'Watering service stopped'
                return

            # TODO Come up with a better way to be notified of stopping
            #      (perhaps use a semaphore/timeout to sleep instead of
            #       time.sleep())
            time.sleep(1.0)

            # TODO Read watering schedules
            # TODO Based on the schedules, start/stop the right zones

    def stop(self):
        print 'Stopping watering service'
        self.stopped = 1
