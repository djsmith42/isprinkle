import sys
import yaml
import mainwidget

from model      import iSprinkleWatering
from webservice import yaml_watering_to_watering, string_to_time, string_to_date

from PyQt4.QtCore    import QUrl, QDateTime, QString, QRegExp
from PyQt4.QtGui     import QApplication, QWidget, QTextEdit
from PyQt4.QtNetwork import QNetworkRequest, QNetworkReply, QNetworkAccessManager

HOST = '192.168.1.3'
PORT = 8080
STATUS_URL    = 'http://%s:%d/status'    % (HOST, PORT)
WATERINGS_URL = 'http://%s:%d/waterings' % (HOST, PORT)

class MainWidget(QWidget):
    def __init__(self, parent=None):
        QWidget.__init__(self, parent)

        self.ui = mainwidget.Ui_MainWidget()
        self.ui.setupUi(self)

        self.ui.stackedWidget.setCurrentWidget(self.ui.connectingPage)
        self.handleError('')

        self.networkManager = QNetworkAccessManager(self)
        self.networkManager.finished.connect(self.networkReply)

        self.refresh()

    def refresh(self):
        self.networkManager.get(QNetworkRequest(QUrl(STATUS_URL)))
        self.networkManager.get(QNetworkRequest(QUrl(WATERINGS_URL)))

    def prettyDateString(self, dateTimeString):
        dateTimeString = QString(dateTimeString).remove(QRegExp('\.\d+$'))
        return QDateTime.fromString(dateTimeString, 'yyyy-MM-dd HH:mm:ss').toString('dddd, MMMM M')

    def prettyTimeString(self, dateTimeString):
        dateTimeString = QString(dateTimeString).remove(QRegExp('\.\d+$'))
        return QDateTime.fromString(dateTimeString, 'yyyy-MM-dd HH:mm:ss').toString('h:mm ap')

    def handleStatus(self, yaml_string):
        self.ui.stackedWidget.setCurrentWidget(self.ui.mainPage)
        try:
            yaml_status = yaml.load(yaml_string)
            dateString   = self.prettyDateString(yaml_status['current time'])
            timeString   = self.prettyTimeString(yaml_status['current time'])
            actionString = yaml_status['current action']
            self.ui.dateLabel.setText(dateString)
            self.ui.timeLabel.setText(timeString)
            self.ui.actionLabel.setText(actionString)
            #if yaml_status['current action'] == 'watering':
            #    self.ui.statusTextEdit.append('Watering Zone ' + str(yaml_status['active zone']))
            self.handleError('')
        except KeyError as e:
            self.handleError('Missing key "' + str(e) + '"')
        except Exception as e:
            self.handleError(str(e))

    def handleWaterings(self, yaml_string):
        yaml_waterings = yaml.load(yaml_string)
        for yaml_watering in yaml_waterings:
            watering = yaml_watering_to_watering(yaml_watering)
            print watering

    def handleError(self, errorString):
        self.ui.errorLabel.setVisible(errorString != '')
        self.ui.errorLabel.setText(errorString)

    def networkReply(self, networkReply):
        if networkReply.error() != QNetworkReply.NoError:
            self.ui.loadingLabel.setText("Oops: " + networkReply.errorString())
            return

        url = str(networkReply.url().toString())
        yaml_string = str(networkReply.readAll())

        if url == STATUS_URL:
            self.handleStatus(yaml_string)
        elif url == WATERINGS_URL:
            self.handleWaterings(yaml_string)
        else:
            print "Woops!"

app = QApplication(sys.argv)
widget = MainWidget()
widget.show()
sys.exit(app.exec_())
