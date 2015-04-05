var axios = require('axios');
var config = require('./config');
var format = require('string-format');
var yaml = require('js-yaml');

function _spaceless(obj) {
  var ret;
  if (Array.isArray(obj)) {
    ret = obj.map(x => _spaceless(x));
  } else if (typeof obj == "object" && obj !== null) {
    ret = {};
    Object.keys(obj).forEach((key) => {
      var spacelessKey = key.replace(/ /g, '_');
      ret[spacelessKey] = _spaceless(obj[key]);
    });
  } else {
    ret = obj;
  }
  return ret;
}

// Clear out the default Axios response transformer, because it throws an uncaught exception when
// trying to parse our API's YAML responses:
axios.defaults.transformResponse.length = 0;
axios.interceptors.response.use((response) => {
  response.data = _spaceless(yaml.load(response.data));
  return response;
});

module.exports = {
  get: function(path) {
    return new Promise((resolve, reject) => {
      var url = format('http://{}:{}{}', config.host, config.port, path);
      axios.get(url)
        .then((response) => resolve(response.data))
        .catch((error) => reject(error));
    });
  }
}
