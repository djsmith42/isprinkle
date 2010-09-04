import datetime

# TODO Add persistence so we can create/update/delete everything here

class iSprinkleWatering:

    # schedule types:
    EVERY_N_DAYS       = 0
    FIXED_DAYS_OF_WEEK = 1
    SINGLE_SHOT        = 2

    def __init__(self, model):
        self.model             = model
        self.enabled           = True
        self.zone_durations    = [] # list of tuples: (zone_number, minutes)
        self.schedule_type     = self.EVERY_N_DAYS
        self.start_time        = datetime.time(8, 0) # 8:00 AM
        self.start_date        = None # only applies to SINGLE_SHOT schedule types
        self.period_days       = 2    # only applies to EVERY_N_DAYS
        self.last_start_time   = None # only applies to EVERY_N_DAYS
        self.days_of_week_mask = None # only applies to FIXED_DAYS_OF_WEEK

    # Setters:
    def add_zone(self, zone_number, minutes):
        self.zone_durations.append((zone_number, minutes))

    def set_schedule_type(self, schedule_type):
        self.schedule_type = schedule_type

    def set_start_time_of_day(self, time_of_day):
        self.start_time = time_of_day

    def set_start_date(self, start_date):
        self.start_date = start_date

    def set_enabled(self, enabled):
        self.enabled = enabled

    def set_period_days(self, days):
        self.period_days = days

    def set_last_start_time(self, last_start_time):
        self.last_start_time = last_start_time

    # Getters:
    def get_zone_durations(self):
        return self.zone_durations

    def get_start_time(self):
        return self.start_time

    def get_schedule_type(self):
        return self.schedule_type

    def get_period_days(self):
        return self.period_days

    def get_last_start_time(self):
        return self.last_start_time

    def is_enabled(self):
        return self.enabled

    def __str__(self):
        return 'Watering: %s' % \
             (self.schedule_type == self.EVERY_N_DAYS       and ('Every %d days' % (self.period_days)) or
             (self.schedule_type == self.SINGLE_SHOT        and ('Single shot on %s at %s' % (self.start_date, self.start_time)) or
             (self.schedule_type == self.FIXED_DAYS_OF_WEEK and ('Every week on %s' % (dow_mask_to_string(self.days_of_week_mask))) or
              'ERROR')))

class iSprinkleModel:

    def __init__(self):
        self._testName = ''
        self.waterings = []
        self.deferral_datetime = None

    def add_watering(self, watering):
        self.waterings.append(watering)

    def get_waterings(self):
        return self.waterings

    def get_deferral_datetime(self):
        return self.deferral_datetime

    def set_deferral_datetime(self, deferral_datetime):
        self.deferral_datetime = deferral_datetime
