import time, datetime, subprocess

from threading import Thread
from model     import iSprinkleModel, iSprinkleWatering

def delta_to_total_minutes(delta):
    return (delta.seconds / 60) + (delta.days * 24 * 60)

def turn_on_zone(zone_number):
    # TODO Read the current relay state and decide if we're actually chaning something. If so, run scripst from a directory (for email notification and such)
    print 'Watering Service: Watering zone', zone_number
    process = subprocess.Popen(['isprinkle-control', '--run-zone', str(zone_number)], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    output = process.communicate()
    if process.returncode is not 0:
        print 'Watering Service: Failed to start zone', zone_number, 'due to error:', output[1]

def turn_off_all_zones():
    # TODO Read the current relay state and decide if we're actually chaning something. If so, run scripst from a directory (for email notification and such)
    print 'Watering Service: Not watering'
    process = subprocess.Popen(['isprinkle-control', '--all-off'], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    output = process.communicate()
    if process.returncode is not 0:
        print 'Watering Service: Failed to turn off all zones (they might already be off anyway) due to error:', output[1]

def get_active_index(watering, now):

    start_time = watering.get_start_time()

    if watering.is_enabled() == False:
        return None

    if watering.schedule_type == iSprinkleWatering.EVERY_N_DAYS:
        # Hack the start_time to look like today:
        start_time = datetime.datetime(now.year, now.month, now.day, start_time.hour, start_time.minute, start_time.second)
        if now >= start_time and (now - datetime.datetime(1970,1,1)).days % watering.get_period_days() == 0:
            index = 0
            for (zone_number, minutes) in watering.get_zone_durations():
                if delta_to_total_minutes(now - start_time) < minutes:
                    return index
                start_time += datetime.timedelta(minutes=minutes)
                index += 1
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
            index = 0
            for (zone_number, minutes) in watering.get_zone_durations():
                if delta_to_total_minutes(now - start_time) < minutes:
                    return index
                start_time += datetime.timedelta(minutes=minutes)
                index += 1
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
            active_index        = None
            active_watering    = None
            in_deferral_period = False

            if self.model.get_deferral_datetime() is not None and now < self.model.get_deferral_datetime():
                print 'Watering Service: In deferral time. Not watering.'
                active_index       = None
                in_deferral_period = True
            else:
                for watering in self.model.get_waterings():
                    active_index = get_active_index(watering, now)
                    if active_index is not None:
                        active_watering = watering
                        break

            self.model.status.in_deferral_period = in_deferral_period

            if active_index is not None:
                print 'Watering Service: Active watering:', active_watering
                turn_on_zone(watering.get_zone_durations()[active_index][0])

                self.model.status.active_watering = active_watering
                if self.model.status.active_index != active_index:
                    self.model.status.active_index = active_index
                    self.model.status.zone_start_time    = datetime.datetime.now()
            else:
                turn_off_all_zones()

                self.model.status.active_watering = None
                self.model.status.active_index    = None
                self.model.status.zone_start_time = None

        print 'Watering service stopped'

    def stop(self):
        print 'Stopping watering service'
        self.stopped = 1
