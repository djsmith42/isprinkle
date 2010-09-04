import time
import datetime

from threading import Thread
from model import iSprinkleModel, iSprinkleWatering

def get_active_zone(watering, now):

    print 'Checking watering', watering, 'against time', now

    start_time = watering.get_start_time()
    start_time = datetime.datetime(now.year, now.month, now.day, start_time.hour, start_time.minute, start_time.second)

    if watering.schedule_type == iSprinkleWatering.EVERY_N_DAYS:

        last_start = watering.get_last_start_time()
        if last_start is None or (now - last_start).days >= watering.get_period_days():
            for (zone_number, minutes) in watering.get_zone_durations():
                if (now - start_time).seconds/60 < minutes:
                    print '  Zone', zone_number, 'should be active'
                    return zone_number
                else:
                    start_time += datetime.timedelta(minutes=minutes)
            print '  None of the zones are within the watering window'
            return None
        else:
            print '  Not enough days have elapsed for this watering'
            return None

    elif watering.schedule_type == iSprinkleWatering.FIXED_DAYS_OF_WEEK:
        print '  Fixed days of the week are not yet supported'
        return None

    elif watering.schedule_type == iSprinkleWatering.SINGLE_SHOT:
        print '  Single shot waterings are not yet supported'
        pass

    return None

class iSprinkleWateringService(Thread):
    def __init__(self, model):
        Thread.__init__(self)
        self.model = model

    def run(self):
        print 'Starting watering service'
        self.stopped = 0
        while not self.stopped:

            time.sleep(1.0)

            print ''
            print 'Checking...'
            print ''
            now = datetime.datetime.now()
            for watering in self.model.get_waterings():
                active_zone_number = get_active_zone(watering, now)
                if active_zone_number is not None:
                    # TODO Activate zone active_zone_number
                    break
            else:
                print 'No active watering at the moment'
                # TODO Turn off all zones

        print 'Watering service stoppedSingle shot waterings are not yet supported'

    def stop(self):
        print 'Stopping watering service'
        self.stopped = 1
