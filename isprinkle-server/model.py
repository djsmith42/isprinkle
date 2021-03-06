import datetime

class iSprinkleStatus:

    def __init__(self):
        self.active_watering    = None
        self.active_index       = None
        self.zone_start_time    = None
        self.in_deferral_period = False

    def __str__(self):
        s = 'iSprinkle Status:\n'
        if self.active_watering is not None:
            s += '  Active Watering: %s' % (self.active_watering.get_uuid())
            s += '  Active Index:    %d\n' % (self.active_index)
            s += '  Start Time:      %s\n' % (str(self.zone_start_time))
        else:
            s += '  No active zone\n'
        return s

class iSprinkleWatering:

    # schedule types:
    EVERY_N_DAYS       = 0
    FIXED_DAYS_OF_WEEK = 1
    SINGLE_SHOT        = 2

    def __init__(self, uuid):
        self.uuid              = uuid
        self.enabled           = None # True
        self.zone_durations    = [] # list of tuples: (zone_number, minutes)
        self.schedule_type     = None # self.EVERY_N_DAYS
        self.start_time        = None # datetime.time(8, 0) # 8:00 AM
        self.start_date        = None # only applies to SINGLE_SHOT schedule types
        self.period_days       = None # only applies to EVERY_N_DAYS
        self.days_of_week_mask = None # only applies to FIXED_DAYS_OF_WEEK

    # Setters:
    def set_uuid(self, uuid_str):
        self.uuid = uuid_str

    def add_zone(self, zone_number, minutes):
        self.zone_durations.append([zone_number, minutes])

    def set_schedule_type(self, schedule_type):
        self.schedule_type = schedule_type

    def set_days_of_week_mask(self, mask):
        self.days_of_week_mask = mask

    def set_start_time_of_day(self, time_of_day):
        self.start_time = time_of_day

    def set_start_date(self, start_date):
        self.start_date = start_date

    def set_enabled(self, enabled):
        self.enabled = enabled

    def set_period_days(self, days):
        self.period_days = days

    # Getters:
    def get_uuid(self):
        return self.uuid

    def get_zone_durations(self):
        return self.zone_durations

    def get_start_time(self):
        return self.start_time

    def get_schedule_type(self):
        return self.schedule_type

    def get_period_days(self):
        return self.period_days

    def get_start_date(self):
        return self.start_date

    def is_enabled(self):
        return self.enabled

    def __str__(self):
        s = 'Watering ID %s\n' % self.uuid
        if self.enabled:
            s += '  Enabled\n'
        else:
            s += '  Disabled\n'

        if self.schedule_type == self.EVERY_N_DAYS:
            s += '  Every %d days, starting at %s' % (self.period_days, self.start_time)
        elif self.schedule_type == self.SINGLE_SHOT:
            s += '  Single shot on %s at %s' % (self.start_date, self.start_time)
        elif self.schedule_type == self.FIXED_DAYS_OF_WEEK:
            s += '  Every week on %s' % (dow_mask_to_string(self.days_of_week_mask))
        else:
            s += '  ERROR'

        for (zone_number, minutes) in self.zone_durations:
            s += '\n    Zone %d: %d minutes' % (zone_number, minutes)

        return s

class iSprinkleModel:

    def __init__(self):
        self.status = iSprinkleStatus()
        self.waterings = []
        self.zone_info = {}
        self.deferral_datetime = None

    def __str__(self):
        s = 'iSprinkle Model:\n'
        s += str(self.status)
        s += 'Waterings (%d):\n' % (len(self.waterings))
        for watering in self.waterings:
            s += str(watering)
        return s

    def add_watering(self, watering):
        self.waterings.append(watering)

    def update_watering(self, watering):
        for i in range(len(self.waterings)):
            if str(self.waterings[i].get_uuid()) == str(watering.get_uuid()):
                self.waterings[i] = watering
                break
        else:
            raise ValueError('No watering with UUID "%s"' % (watering.get_uuid())) 

    def set_zone_info(self, zone_info):
        self.zone_info = zone_info

    def find_watering(self, uuid_str):
        for watering in self.waterings:
            if str(watering.get_uuid()) == str(uuid_str):
                return watering
        else:
            raise ValueError('Not watering with UID "%s"' % (uuid_str))

    def delete_watering(self, uuid_str):
        for i in range(len(self.waterings)):
            if str(self.waterings[i].get_uuid()) == str(uuid_str):
                del self.waterings[i]
                break
        else:
            raise ValueError('No watering with UUID "%s"' % (uuid_str))

    def get_waterings(self):
        return self.waterings

    def get_deferral_datetime(self):
        return self.deferral_datetime

    def set_deferral_datetime(self, deferral_datetime):
        self.deferral_datetime = deferral_datetime

    def get_zone_info(self):
        return self.zone_info
