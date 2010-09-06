import time, datetime, subprocess

from threading import Thread
from model     import iSprinkleModel, iSprinkleWatering

def turn_on_zone(zone_number):
    print 'Watering Service: Watering zone', zone_number
    process = subprocess.Popen(['isprinkle-control', '--run-zone', str(zone_number)], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    output = process.communicate()
    if process.returncode is not 0:
        print 'Watering Service: Failed to start zone', zone_number, 'due to error:', output[1]

def turn_off_all_zones():
    print 'Watering Service: Not watering'
    process = subprocess.Popen(['isprinkle-control', '--all-off'], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    output = process.communicate()
    if process.returncode is not 0:
        print 'Watering Service: Failed to turn off all zones (they might already be off anyway) due to error:', output[1]

def get_active_zone(watering, now):

    start_time = watering.get_start_time()

    start_time = datetime.datetime(now.year, now.month, now.day, start_time.hour, start_time.minute, start_time.second)
    if watering.schedule_type == iSprinkleWatering.EVERY_N_DAYS:

        if (now - datetime.datetime(1970,1,1)).days % watering.get_period_days() == 0:
            for (zone_number, minutes) in watering.get_zone_durations():
                if (now - start_time).seconds/60 < minutes:
                    return zone_number
                else:
                    start_time += datetime.timedelta(minutes=minutes)
            return None
        else:
            return None

    elif watering.schedule_type == iSprinkleWatering.FIXED_DAYS_OF_WEEK:
        print '  Fixed days of the week are not yet supported'
        return None

    elif watering.schedule_type == iSprinkleWatering.SINGLE_SHOT:

        start_time = datetime.datetime(
                watering.get_start_date().year,
                watering.get_start_date().month,
                watering.get_start_date().day,
                watering.get_start_time().hour,
                watering.get_start_time().minute,
                watering.get_start_time().second)

        if now >= start_time:
            for (zone_number, minutes) in watering.get_zone_durations():
                tmp = (now - start_time).seconds/60
                if tmp < minutes:
                    return zone_number
                start_time += datetime.timedelta(minutes=minutes)
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

            now = datetime.datetime.now()
            print 'Watering Service: Current Time', now
            active_zone_number = None
            active_watering    = None

            if self.model.get_deferral_datetime() is not None and now < self.model.get_deferral_datetime():
                print 'Watering Service: In deferral time. Not watering.'
                active_zone_number = None
            else:
                for watering in self.model.get_waterings():
                    active_zone_number = get_active_zone(watering, now)
                    if active_zone_number is not None:
                        active_watering = watering
                        break

            if active_zone_number is not None:
                print 'Watering Service: Active watering:', active_watering
                turn_on_zone(active_zone_number)
            else:
                turn_off_all_zones()

            self.model.status.active_watering = active_watering
            if self.model.status.active_zone_number != active_zone_number:
                self.model.status.active_zone_number = active_zone_number
                self.model.status.zone_start_time    = datetime.datetime.now()

    def stop(self):
        print 'Stopping watering service'
        self.stopped = 1
