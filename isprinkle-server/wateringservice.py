import time
from threading import Thread
from model import iSprinkleModel, iSprinkleWatering

class iSprinkleWateringService(Thread):
    def __init__(self, model):
        Thread.__init__(self)
        self.model = model

    def run(self):
        print 'Starting watering service'
        self.stopped = 0
        while not self.stopped:

            # TODO Come up with a better way to be notified of stopping
            #      (perhaps use a semaphore/timeout to sleep instead of
            #       time.sleep())
            time.sleep(1.0)

            print 'Watering Service: There are', len(self.model.get_waterings()), 'watering schedules'
            for watering in self.model.get_waterings():
                print '   ', watering
                pass
            # TODO Read watering schedules
            # TODO Based on the schedules, start/stop the right zones

        print 'Watering service stopped'

    def stop(self):
        print 'Stopping watering service'
        self.stopped = 1
