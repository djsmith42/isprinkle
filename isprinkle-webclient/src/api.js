var axios = require('axios');
var config = require('./config');
var format = require('string-format');
var yaml = require('js-yaml');
var ErrorStore = require('./stores/ErrorStore');

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

function _spacify(obj) {
  var ret;
  if (Array.isArray(obj)) {
    ret = obj.map(x => _spacify(x));
  } else if (typeof obj == "object" && obj !== null) {
    ret = {};
    Object.keys(obj).forEach((key) => {
      var spacefulKey = key.replace(/_/g, ' ');
      ret[spacefulKey] = _spacify(obj[key]);
    });
  } else {
    ret = obj;
  }
  return ret;
}

axios.interceptors.response.use((response) => {
  response.data = _spaceless(yaml.load(response.data));
  return response;
}, function(error, foo, bar) {
  ErrorStore.setError(error);
});

function _url(path) {
  if (process.env.DEV) {
      return format('http://{}:{}{}', config.host, config.port, path);
  } else {
      return path;
  }
}

module.exports = {
  get: function(path) {
    return new Promise((resolve, reject) => {
      axios.get(_url(path))
        .then((response) => resolve(response.data))
        .catch((error) => reject(error));
    });
  },
  post: function(path, payload) {
    return new Promise((resolve, reject) => {
      axios.post(_url(path), _spacify(payload))
        .then((response) => resolve(response.data))
        .catch((error) => reject(error));
    });
  }
}
