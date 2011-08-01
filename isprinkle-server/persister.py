import pickle
from model import iSprinkleModel

PICKLE_PROTOCOL_VERSION = 0

FILE_PATH = '/opt/isprinkle-server/model.pickle'

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

	    # Clean up fields that have changed:
	    model.status.active_index = None;       # added 2011-08-01
	    model.status.active_zone_number = None; # removed 2011-08-01
        except:
            pass
        return model
