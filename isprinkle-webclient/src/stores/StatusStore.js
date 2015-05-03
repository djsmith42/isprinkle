var api = require('../api');
var EventEmitter = require('events').EventEmitter;
var assign = require('object-assign');
var moment = require('moment');

module.exports =  assign({}, EventEmitter.prototype, {
  CHANGE_EVENT: '__change__',
  fetch: function() {
    return api.get('/status').then((status) => {
      if (status.deferral_datetime === 'None') {
        status.deferral_datetime = null;
      }
      this._status = status;
      this.emit(this.CHANGE_EVENT);
    });
  },
  start: function() {
    this._status = null;
    return this._fetchLoop();
  },
  _fetchLoop: function() {
    return this.fetch().then(() => {
      setTimeout(this._fetchLoop.bind(this), 3000);
    })
  },
  status: function() {
    return this._status;
  },
  clearDeferralTime: function() {
    return this._doPost('/clear-deferral-time');
  },
  setDeferralTime: function(date) {
    var payload = moment(date).format("YYYY-MM-DD HH:mm:ss");
    return this._doPost('/set-deferral-time', payload);
  },
  _doPost: function(url, payload) {
    var self = this;
    return new Promise((resolve, reject) => {
      api.post(url, payload).then(function() {
        setTimeout(function() {
          self.fetch().then(function() {
            resolve();
          });
        }, 1500);
      });
    });
  }
});
