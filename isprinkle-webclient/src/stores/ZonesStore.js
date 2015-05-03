var api = require('../api');
var assign = require('object-assign');
var EventEmitter = require('events').EventEmitter;

module.exports = assign({}, EventEmitter.prototype, {
  CHANGE_EVENT: '__change__',
  fetch: function() {
    return api.get('/zone-info').then((_zones) => {
      this._zones = _zones;
      this.emit(this.CHANGE_EVENT);
    });
  },
  zones: function() {
    return this._zones;
  },
});
