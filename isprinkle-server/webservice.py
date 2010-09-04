from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from threading      import Thread

class iSprinkleHandler(BaseHTTPRequestHandler):

    def do_GET(self):

        if self.path == '/zone-info':
            print 'Request for zone info'
        elif self.path == '/watering-status':
            print 'Request for watering status'
        elif self.path == '/watering-records':
            print 'Request for watering records'

        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write('This doesn\'t work yet!');

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

class iSprinkleWebService(Thread):

    def run(self):
        try:
            print 'Starting web service'
            self.server = HTTPServer(('', 8080), iSprinkleHandler)
        except:
            print 'Could not start web service'

        try:
            self.server.serve_forever()
        except:
            print 'Web service stopped'

    def stop(self):
        print 'Stopping web service'
        self.server.server_close()
