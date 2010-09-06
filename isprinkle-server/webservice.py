from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from model          import iSprinkleWatering,  iSprinkleModel
from threading      import Thread

import datetime
import yaml

WEB_SERVICE_PORT = 8080

class iSprinkleHandler(BaseHTTPRequestHandler):

    def do_GET(self):

        if self.path == '/status':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()

            active_zone = self.server.model.status.active_zone_number

            yaml_status = { 'current time' : str(datetime.datetime.now()),
                            'active zone'  : active_zone }

            if active_zone is not None:
                zone_start_time  = self.server.model.status.zone_start_time
                yaml_status['start time'] = str(zone_start_time)

            self.wfile.write(yaml.dump(yaml_status))

        elif self.path == '/waterings':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()

            yaml_waterings = []
            for watering in self.server.model.get_waterings():
                yaml_waterings.append({
                    'schedule type'  : watering.get_schedule_type(),
                    'period days'    : watering.get_period_days(),
                    'enabled'        : watering.is_enabled(),
                    'start time'     : str(watering.get_start_time()),
                    'zone durations' : watering.get_zone_durations()})
            self.wfile.write(yaml.dump(yaml_waterings))

        else:
            self.send_response(404)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write('Oops')

    def do_POST(self):

        if self.path == '/set-zone-name':
            print 'Request to rename zone'
        elif self.path == '/set-zone-default-time':
            print 'Request to rename zone'
        elif self.path == '/add-watering':
            print 'Request to add a watering'
        elif self.path == '/delete-watering':
            print 'Request to delete a watering'
        elif self.path == '/update-watering':
            print 'Request to update a watering'
        elif self.path == '/defer-waterings':
            print 'Request to defer all waterings'
        elif self.path == '/run-single-shot':
            print 'Request to run a zone'

        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write('This doesn\'t work yet!');

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
