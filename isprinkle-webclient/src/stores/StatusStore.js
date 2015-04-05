var api = require('../api');
var config = require('../config');
var EventEmitter = require('events').EventEmitter;
var assign = require('object-assign');
var _ = require('lodash');

var StatusStore = assign({}, EventEmitter.prototype, {
  CHANGE_EVENT: '__change__',
  fetch: function() {
    return api.get('/status').then((status) => {
      if (!_.isEqual(status, this._status)) {
        this._status = status;
        this.emit(this.CHANGE_EVENT);
      }
    });
  },
  start: function() {
    if (!this._started) {
      this._started = true;
      this._status = null;
      this._fetchLoop();
    }
  },
  _fetchLoop: function() {
    this.fetch().then(() => {
      setTimeout(this._fetchLoop.bind(this), 1000);
    })
  },
  status: function() {
    return this._status;
  }
});

module.exports = StatusStore;
