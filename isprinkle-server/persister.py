import pickle
from model import iSprinkleModel

PICKLE_PROTOCOL_VERSION = 0

FILE_PATH = '/var/lib/isprinkle/model.pickle'

class iSprinklePersister:

    def save(self, model):
        pickle_str = pickle.dumps(model, PICKLE_PROTOCOL_VERSION)

        f = open(FILE_PATH, 'wb')
        f.write(pickle_str)
        f.close()

    def load(self):
        model = iSprinkleModel()
        try:
            f = open(FILE_PATH, 'rb')
            model = pickle.load(f)
            f.close()
        except:
            pass
        return model
