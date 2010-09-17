import sys
import yaml
import mainwidget

from PyQt4.QtCore    import QUrl
from PyQt4.QtGui     import QApplication, QWidget, QTextEdit
from PyQt4.QtNetwork import QNetworkRequest, QNetworkAccessManager

HOST='192.168.1.26'
PORT=8080
STATUS_URL='http://%s:%d/status' % (HOST, PORT)

class MainWidget(QWidget):
    def __init__(self, parent=None):
        QWidget.__init__(self, parent)

        self.ui = mainwidget.Ui_MainWidget()
        self.ui.setupUi(self)

        self.ui.testButton.clicked.connect(self.buttonClicked)

        self.networkManager = QNetworkAccessManager(self)
        self.networkManager.finished.connect(self.networkReply)

        self.buttonClicked()

    def buttonClicked(self):
        self.ui.textEdit.clear()
        self.ui.textEdit.append('Loading...')
        self.networkManager.get(QNetworkRequest(QUrl(STATUS_URL)))

    def networkReply(self, networkReply):
        self.ui.textEdit.clear()
        yaml_string = str(networkReply.readAll())
        try:
            yaml_status = yaml.load(yaml_string)
            self.ui.textEdit.append('Current Time: ' + yaml_status['current time'])
            self.ui.textEdit.append('Currently: ' + yaml_status['current action'])
            if yaml_status['current action'] == 'watering':
                self.ui.textEdit.append('Watering Zone ' + str(yaml_status['active zone']))
        except KeyError as e:
            self.ui.textEdit.append('Error: Web service is missing key "' + str(e) + "'")
        except Exception as e:
            self.ui.textEdit.append('Error: ' + str(e))

app = QApplication(sys.argv)
widget = MainWidget()
widget.show()
sys.exit(app.exec_())
