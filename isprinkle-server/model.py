class iSprinkleModel:

    def __init__(self):
        self._testName = ''

    def setTestName(self, name):
        self._testName = name

    def testName(self):
        return self._testName
