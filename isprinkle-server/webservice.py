from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from model          import iSprinkleWatering,  iSprinkleModel
from persister      import iSprinklePersister
from threading      import Thread

import datetime
import yaml

WEB_SERVICE_PORT = 8080

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
            active_zone     = self.server.model.status.active_zone_number
            active_watering = self.server.model.status.active_watering

            yaml_status = {}
            yaml_status['current time'] = str(datetime.datetime.now())

            if active_watering:
                yaml_status['current action' ] = 'watering'
                yaml_status['active zone'    ] = active_zone
                yaml_status['active watering'] = str(active_watering.get_uuid())
                yaml_status['start time']      = str(zone_start_time)
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
        response_content = ''

        post_data_length = self.headers.getheader('content-length')
        post_data = None
        if post_data_length:
            post_data_length = int(post_data_length)
            post_data = self.rfile.read(post_data_length)

            if self.path == '/update-watering':
                response_code, response_content = handle_update_watering(post_data)
            elif self.path == '/add-watering':
                print 'Request to add a watering'
            elif self.path == '/delete-watering':
                print 'Request to delete a watering'
            elif self.path == '/set-deferral-time':
                print 'Request to set the deferral time'
        else:
            response_code = 500
            response_content = 'Your request is missing the content-length header'

        self.send_response(response_code)
        self.send_header('Content-type', content_type)
        self.send_header('Content-length', len(response_content))
        self.end_headers()
        self.wfile.write(response_content)

    def handle_update_watering(post_data):
        print 'Request to update a watering:'
        try:
            yaml_watering = yaml.load(post_data)
        except:
            return (500, 'Malformed YAML')

        try:
            watering = iSprinkleWatering()
            watering.set_uuid(yaml_watering['uuid'])
            watering.set_schedule_type(yaml_watering['schedule type'])
            watering.set_enabled(yaml_watering['enabled'])
            watering.set_start_date(time.strptime(yaml_watering['start time'], '%H:%M:%S'))
            for zone_duration in yaml_watering['zone durations']:
                watering.aadd_zone(zone_duration[0], zone_duration[1])
            if schedule_type == iSprinkleWatering.EVERY_N_DAYS:
                watering.set_period_days(yaml_watering['period days'])
            elif schedule_type == iSprinkleWatering.SINGLE_SHOT:
                # TODO Test this
                watering.set_start_date(datetime.strptime(yaml_watering['start date'], '%Y-%m-%d'))
            elif schedule_type == iSprinkleWatering.FIXED_DAYS_OF_WEEK:
                watering.set_days_of_week_mask(yaml_watering['days of week'])

            for watering in self.server.model.get_waterings():
                if watering.get_uuid() == watering_uuid:
                    # TODO Replace the watering
                    iSprinklePersister().save(model)
                    break
            else:
                return (500, 'No watering with that UUID')
        except ValueError as error:
            return (500, 'Bad time format. Should be 17:45:00')
        except KeyError as error:
            return (500, 'Missing field "%s" in YAML stream' % (str(error)))

        # TODO Grab the rest of the watering fields from yaml_watering
        # TODO Validate the watering data


        return (200, 'watering updated')

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
