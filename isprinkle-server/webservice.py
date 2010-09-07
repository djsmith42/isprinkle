from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from model          import iSprinkleWatering,  iSprinkleModel
from threading      import Thread

import datetime
import yaml

WEB_SERVICE_PORT = 8080

class iSprinkleHandler(BaseHTTPRequestHandler):

    # Version 1.1's persistent connections cause our thread to not shut down cleanly:
    protocol_version = 'HTTP/1.0'

    # To remove the 'Server:' header:
    server_version   = ''
    sys_version      = ''

    def date_time_string(timestamp=None):
        # To remove the 'Date:' header
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
                print 'Request to update a watering:'
                try:
                    yaml_watering = yaml.load(post_data)
                    watering_uuid = yaml_watering['uuid']
                    print 'Request to update watering with UUID', watering_uuid
                    # TODO Validate the watering data
                    # TODO Find the watering in the model and update it
                    # TODO Persist the model
                    response_content = 'ok'
                except:
                    response_code = 500
                    response_content = 'Malformed YAML'
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
