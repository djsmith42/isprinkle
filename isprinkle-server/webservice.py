from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from model          import iSprinkleWatering,  iSprinkleModel
from persister      import iSprinklePersister
from threading      import Thread

import datetime
import time
import yaml
import uuid
import re

WEB_SERVICE_PORT = 8080

def string_to_time(time_string):
    st_time = time.strptime(time_string, '%H:%M:%S') # this is an instance of time.struct_time
    return datetime.time(st_time.tm_hour, st_time.tm_min, st_time.tm_sec)

def string_to_date(date_string):
    st_time = time.strptime(date_string, '%Y-%m-%d') # this is an instance of time.struct_time
    return datetime.date(st_time.tm_year, st_time.tm_mon, st_time.tm_mday)

def string_to_datetime(datetime_string):
    st_time = time.strptime(datetime_string, '%Y-%m-%d %H:%M:%S') # this is an instance of time.struct_time
    return datetime.datetime(st_time.tm_year, st_time.tm_mon, st_time.tm_mday, st_time.tm_hour, st_time.tm_min, st_time.tm_sec)

def yaml_watering_to_watering(yaml_watering):
    try:
        watering_uuid = ''
        if yaml_watering.has_key('uuid'):
            watering_uuid = yaml_watering['uuid']
        watering = iSprinkleWatering(watering_uuid)
        watering.set_schedule_type(yaml_watering['schedule type'])
        watering.set_enabled(yaml_watering['enabled'])
        watering.set_start_time_of_day(string_to_time(yaml_watering['start time']))
        for zone_duration in yaml_watering['zone durations']:
            watering.add_zone(zone_duration[0], zone_duration[1])
        if yaml_watering['schedule type'] == iSprinkleWatering.EVERY_N_DAYS:
            watering.set_period_days(yaml_watering['period days'])
        elif yaml_watering['schedule type'] == iSprinkleWatering.SINGLE_SHOT:
            # TODO Test this
            watering.set_start_date(string_to_date(yaml_watering['start date']))
        elif yaml_watering['schedule type'] == iSprinkleWatering.FIXED_DAYS_OF_WEEK:
            watering.set_days_of_week_mask(yaml_watering['days of week'])
        return watering
    except ValueError as error:
        raise Exception('Bad time format. Should be 17:45:00')
    except KeyError as error:
        raise Exception('Missing field "%s" in YAML stream' % (str(error)))

def yaml_to_watering(yaml_string):
    return yaml_watering_to_watering(yaml.load(yaml_string))

def handle_add_watering(model, post_data):
    watering = yaml_to_watering(post_data)
    watering.set_uuid(str(uuid.uuid4()))
    model.add_watering(watering)
    iSprinklePersister().save(model)
    return str(watering.get_uuid())

def handle_update_watering(model, post_data):
    watering = yaml_to_watering(post_data)
    model.update_watering(watering)
    iSprinklePersister().save(model)

def handle_delete_watering(model, post_data):
    uuid_str = post_data.strip()
    model.delete_watering(uuid_str)
    iSprinklePersister().save(model)

def handle_delete_all_single_shot_waterings(model, post_data):
    uuids_to_delete = []
    for watering in model.get_waterings():
        if watering.schedule_type == iSprinkleWatering.SINGLE_SHOT:
            uuids_to_delete.append(watering.get_uuid())

    for uuid in uuids_to_delete:
        print "Deleting watering", watering.get_uuid();
        model.delete_watering(uuid)
        print "Waterings left:", str(len(model.get_waterings()))

    iSprinklePersister().save(model)

    return "Deleted " + len(uuids_to_delete) + " waterings"

def handle_set_deferral_datetime(model, post_data):
    dt = string_to_datetime(post_data.strip())
    model.set_deferral_datetime(dt)
    iSprinklePersister().save(model)

def handle_clear_deferral_datetime(model):
    model.set_deferral_datetime(None)
    iSprinklePersister().save(model)

def handle_run_zone_now(model, post_data):
    new_watering = create_single_shot_watering(datetime.datetime.now())
    post_data = post_data.strip()
    elements = post_data.split(' ')
    zone    = int(elements[0])
    minutes = int(elements[1])
    new_watering.add_zone(zone, minutes)
    model.add_watering(new_watering)
    iSprinklePersister().save(model)
    return str(new_watering.get_uuid())

def handle_disable_watering(model, post_data):
    uuid_str = post_data.strip()
    model.find_watering(uuid_str).set_enabled(False)
    iSprinklePersister().save(model)

def handle_enable_watering(model, post_data):
    uuid_str = post_data.strip()
    model.find_watering(uuid_str).set_enabled(True)
    iSprinklePersister().save(model)

def handle_run_watering_now(model, post_data):
    new_watering = create_single_shot_watering(datetime.datetime.now())
    uuid_str = post_data.strip()
    for zone_duration in model.find_watering(uuid_str).get_zone_durations():
        new_watering.add_zone(zone_duration[0], zone_duration[1])

    print 'Adding new single shot watering:', new_watering
    model.add_watering(new_watering)
    iSprinklePersister().save(model)
    return str(new_watering.get_uuid())

def create_single_shot_watering(dt): # dt is a datetie.datetime instnace
    new_watering = iSprinkleWatering(str(uuid.uuid4()))
    new_watering.set_schedule_type(iSprinkleWatering.SINGLE_SHOT)
    new_watering.set_enabled(True)
    new_watering.set_start_date(dt.date())
    new_watering.set_start_time_of_day(dt.time())
    return new_watering

class iSprinkleHandler(BaseHTTPRequestHandler):

    # Version 1.1's persistent connections cause our thread to not shut down cleanly:
    protocol_version = 'HTTP/1.0'

    # This removes the 'Server:' header:
    server_version   = ''
    sys_version      = ''

    def date_time_string(timestamp=None):
        # This removes the 'Date:' header
        return ''

    def do_GET(self):

        response_code = 200
        content_type = 'text/plain'
        response_content = ''

        if self.path == '/status':
            active_zone        = self.server.model.status.active_zone_number
            active_watering    = self.server.model.status.active_watering
            in_deferral_period = self.server.model.status.in_deferral_period

            yaml_status = {}
            yaml_status['current time'      ] = re.sub("\.\d+$", "", str(datetime.datetime.now()))
            yaml_status['in deferral period'] = in_deferral_period
            yaml_status['deferral datetime' ] = str(self.server.model.get_deferral_datetime())

            if active_watering:
                yaml_status['current action' ] = 'watering'
                yaml_status['active zone'    ] = active_zone
                yaml_status['active watering'] = str(active_watering.get_uuid())
            else:
                yaml_status['current action' ] = 'idle'

            response_content = yaml.dump(yaml_status)

        elif self.path == '/waterings':
            yaml_waterings = []
            for watering in self.server.model.get_waterings():
                yaml_watering = {
                        'uuid'           : str(watering.get_uuid()),
                        'schedule type'  : watering.get_schedule_type(),
                        'enabled'        : watering.is_enabled(),
                        'start time'     : str(watering.get_start_time()),
                        'zone durations' : watering.get_zone_durations()
                        }
                if watering.get_schedule_type() == iSprinkleWatering.EVERY_N_DAYS:
                    yaml_watering['period days'] = watering.get_period_days()
                if watering.get_schedule_type() == iSprinkleWatering.SINGLE_SHOT:
                    yaml_watering['start date'] = watering.get_start_date()
                if watering.get_schedule_type() == iSprinkleWatering.FIXED_DAYS_OF_WEEK:
                    yaml_watering['days of week'] = 'TODO'

                yaml_waterings.append(yaml_watering)

            response_content = yaml.dump(yaml_waterings)

        else:
            response_code = 404
            response_content = 'Oops'

        self.send_response(response_code)
        self.send_header('Content-type',   content_type)
        self.send_header('Content-length', len(response_content))
        self.end_headers()
        self.wfile.write(response_content)

    def do_POST(self):

        response_code    = 200
        content_type     = 'text/plain'
        response_content = 'ok'

        post_data_length = self.headers.getheader('content-length')
        post_data = None
        if post_data_length:
            post_data_length = int(post_data_length)
            post_data = self.rfile.read(post_data_length)

            try:
                if self.path == '/update-watering':
                    print 'Request to update a watering'
                    handle_update_watering(self.server.model, post_data)
                elif self.path == '/add-watering':
                    print 'Request to add a watering'
                    response_content = handle_add_watering(self.server.model, post_data)
                elif self.path == '/delete-watering':
                    print 'Request to delete a watering'
                    handle_delete_watering(self.server.model, post_data)
                elif self.path == '/delete-all-single-shot-waterings':
                    print 'Request to delete all single shot waterings'
                    response_content = handle_delete_all_single_shot_waterings(self.server.model, post_data)
                elif self.path == '/set-deferral-time':
                    print 'Request to set the deferral time'
                    handle_set_deferral_datetime(self.server.model, post_data)
                elif self.path == '/clear-deferral-time':
                    print 'Request to clear the deferral time'
                    handle_clear_deferral_datetime(self.server.model)
                elif self.path == '/run-watering-now':
                    print 'Request to run watering now'
                    response_content = handle_run_watering_now(self.server.model, post_data)
                elif self.path == '/run-zone-now':
                    print 'Request to run single zone now'
                    response_content = handle_run_zone_now(self.server.model, post_data)
                elif self.path == '/disable-watering':
                    print 'Request to disable a watering'
                    handle_disable_watering(self.server.model, post_data)
                elif self.path == '/enable-watering':
                    print 'Request to enable a watering'
                    handle_enable_watering(self.server.model, post_data)
                else:
                    response_code    = 404
                    response_content = 'No such path'
            except Exception as e:
                response_code    = 400
                response_content = str(e)
        else:
            response_code    = 411
            response_content = 'Your request is missing the content-length header'

        print '   Response: %d: %s' % (response_code, response_content)
        self.send_response(response_code)
        self.send_header('Content-type', content_type)
        self.send_header('Content-length', len(response_content))
        self.end_headers()
        self.wfile.write(response_content)

class iSprinkleHttpServer(HTTPServer):

    def __init__(self, model):
        HTTPServer.__init__(self, ('', WEB_SERVICE_PORT), iSprinkleHandler)
        self.model = model

class iSprinkleWebService(Thread):

    def __init__(self, model):
        Thread.__init__(self)
        print 'Starting web service'
        self.server = iSprinkleHttpServer(model)

    def run(self):
        try:
            self.server.serve_forever()
        except:
            print 'Web service stopped'

    def stop(self):
        print 'Stopping web service'
        self.server.server_close()
