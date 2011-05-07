import sys
import time
import datetime

try:
    from PyQt4.QtCore    import QUrl, QDateTime, QString, QRegExp, QTimer
    from PyQt4.QtGui     import QApplication, QWidget, QTextEdit, QListWidgetItem
    from PyQt4.QtNetwork import QNetworkRequest, QNetworkReply, QNetworkAccessManager
except:
    print "This application requires PyQt4. Please install it."
    sys.exit(1)

try:
    import yaml
except:
    print "This application requires the python yaml module. Please install it."
    sys.exit(1)

import mainwidget

from model      import iSprinkleWatering
from webservice import yaml_watering_to_watering, string_to_time, string_to_date

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

        self.refreshStatus()
        self.refreshWaterings()

    def refreshStatus(self):
        self.networkManager.get(QNetworkRequest(QUrl(STATUS_URL)))

    def refreshWaterings(self):
        self.networkManager.get(QNetworkRequest(QUrl(WATERINGS_URL)))

    def prettyDateString(self, dateTimeString):
        dateTimeString = QString(dateTimeString).remove(QRegExp('\.\d+$'))
        return QDateTime.fromString(dateTimeString, 'yyyy-MM-dd HH:mm:ss').toString('dddd, MMMM M')

    def prettyTimeString(self, dateTimeString):
        dateTimeString = QString(dateTimeString).remove(QRegExp('\.\d+$'))
        return QDateTime.fromString(dateTimeString, 'yyyy-MM-dd HH:mm:ss').toString('h:mm ap')

    def prettyDateTimeDelta(self, datetime1, datetime2):
        delta = datetime1 - datetime2
        hours = int(delta.seconds / 3600)
        minutes = (delta.seconds - (hours / 60)) / 60
        if delta.days == 1:
            return "1 day, %d hours" % (hours)
        elif delta.days > 1:
            return "%d days" % (delta.days)
        elif hours == 1:
            if minutes == 0:
                return "1 hour"
            elif minutes == 1:
                return "1 hour, 1 minute"
            else:
                return "1 hour, %d minutes" % (minutes)
        else:
            return "%d hours" % (hours)

    def stringToDateTime(self, datetime_string):
        datetime_string = str(QString(datetime_string).remove(QRegExp('\.\d+$')))
        st_time = time.strptime(datetime_string, '%Y-%m-%d %H:%M:%S')
        return datetime.datetime(st_time.tm_year, st_time.tm_mon, st_time.tm_mon, st_time.tm_hour, st_time.tm_min, st_time.tm_sec)

    def handleStatus(self, yaml_string):
        QTimer.singleShot(1000, self.refreshStatus)
        self.ui.stackedWidget.setCurrentWidget(self.ui.mainPage)
        try:
            yaml_status = yaml.load(yaml_string)
            dateString   = self.prettyDateString(yaml_status['current time'])
            timeString   = self.prettyTimeString(yaml_status['current time'])
            actionString = yaml_status['current action']
            deferralDate = self.prettyDateString(yaml_status['deferral datetime'])
            deferralTime = self.prettyTimeString(yaml_status['deferral datetime'])
            extraInfo    = ''
            if yaml_status['in deferral period']:
                extraInfo = "Not watering until <b>" + deferralDate + "</b>"
                extraInfo += "<br>(%s)" % (self.prettyDateTimeDelta(self.stringToDateTime(yaml_status['current time']), self.stringToDateTime(yaml_status['deferral datetime'])))
            self.ui.dateLabel.setText(dateString)
            self.ui.timeLabel.setText(timeString)
            self.ui.actionLabel.setText(actionString)
            self.ui.extraInfoLabel.setText(extraInfo)
            self.ui.extraInfoFrame.setVisible(extraInfo != '')
            self.handleError('')
        except KeyError as e:
            self.handleError('Missing key "' + str(e) + '"')
        except Exception as e:
            self.handleError(str(e))

    def handleWaterings(self, yaml_string):
        yaml_waterings = yaml.load(yaml_string)
        for yaml_watering in yaml_waterings:
            watering = yaml_watering_to_watering(yaml_watering)
            text = ''
            if watering.get_schedule_type() == iSprinkleWatering.EVERY_N_DAYS:
                if watering.get_period_days() == 1:
                    text = 'Every day'
                else:
                    text = 'Every %d days' % (watering.get_period_days())
                text += ' at %s' % (watering.get_start_time())

            elif watering.get_schedule_type() == iSprinkleWatering.SINGLE_SHOT:
                text = 'Single shot on %s at %s' % (watering.get_start_date(), watering.get_start_time())

            item = QListWidgetItem(text, self.ui.wateringListWidget)

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
