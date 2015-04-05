var api = require('../api');
var config = require('../config');

module.exports = {
  fetch: () => {
    api.get('/status').then((status) => {
      this._status = status;
      console.log("_status:", this._status);
    }
  )},
  status: () => {
    return this._status;
  }
}
