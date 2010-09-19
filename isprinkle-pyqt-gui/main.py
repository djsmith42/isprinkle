import sys
import yaml
import mainwidget

from model      import iSprinkleWatering
from webservice import yaml_watering_to_watering, string_to_time, string_to_date

from PyQt4.QtCore    import QUrl
from PyQt4.QtGui     import QApplication, QWidget, QTextEdit
from PyQt4.QtNetwork import QNetworkRequest, QNetworkAccessManager

HOST = '192.168.1.26'
PORT = 8080
STATUS_URL    = 'http://%s:%d/status'    % (HOST, PORT)
WATERINGS_URL = 'http://%s:%d/waterings' % (HOST, PORT)

class MainWidget(QWidget):
    def __init__(self, parent=None):
        QWidget.__init__(self, parent)

        self.ui = mainwidget.Ui_MainWidget()
        self.ui.setupUi(self)

        self.ui.refreshButton.clicked.connect(self.refreshClicked)

        self.networkManager = QNetworkAccessManager(self)
        self.networkManager.finished.connect(self.networkReply)

        self.refreshClicked()

    def refreshClicked(self):
        self.ui.statusTextEdit.clear()
        self.ui.statusTextEdit.append('Loading...')
        self.networkManager.get(QNetworkRequest(QUrl(STATUS_URL)))
        self.networkManager.get(QNetworkRequest(QUrl(WATERINGS_URL)))

    def networkReply(self, networkReply):
        url = str(networkReply.url().toString())
        yaml_string = str(networkReply.readAll())

        if url == STATUS_URL:
            self.ui.statusTextEdit.clear()
            try:
                yaml_status = yaml.load(yaml_string)
                self.ui.statusTextEdit.append('Current Time: ' + yaml_status['current time'])
                self.ui.statusTextEdit.append('Currently: ' + yaml_status['current action'])
                if yaml_status['current action'] == 'watering':
                    self.ui.statusTextEdit.append('Watering Zone ' + str(yaml_status['active zone']))
            except KeyError as e:
                self.ui.statusTextEdit.append('Error: Web service is missing key "' + str(e) + "'")
            except Exception as e:
                self.ui.statusTextEdit.append('Error: ' + str(e))
        elif url == WATERINGS_URL:
            yaml_waterings = yaml.load(yaml_string)
            for yaml_watering in yaml_waterings:
                watering = yaml_watering_to_watering(yaml_watering)
                print watering

app = QApplication(sys.argv)
widget = MainWidget()
widget.show()
sys.exit(app.exec_())
