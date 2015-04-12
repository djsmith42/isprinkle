var api = require('../api');
var assign = require('object-assign');
var EventEmitter = require('events').EventEmitter;
var ZonesStore = require('./Zones');
var clone = require('clone');

var WateringsStore = assign({}, EventEmitter.prototype, {
  CHANGE_EVENT: '__change__',
  start: function() {
    var self = this;
    self._waterings = null;
    ZonesStore.fetch().then(function() {
      self._fetchLoop();
      ZonesStore.on(ZonesStore.CHANGE_EVENT, () => {
        self._waterings = self._applyZoneNames(self._waterings);
      });
    });
  },
  fetch: function() {
    return api.get('/waterings').then((waterings) => {
      this._waterings = this._applyZoneNames(waterings);
      this.emit(this.CHANGE_EVENT);
    });
  },
  waterings: function() {
    return this._waterings;
  },
  _fetchLoop: function() {
    this.fetch().then(() => {
      setTimeout(this._fetchLoop.bind(this), 3000);
    });
  },
  _applyZoneNames: function(waterings) {
    return waterings.map((watering) => {
      var watering = clone(watering)
      watering.zone_durations = watering.zone_durations.map((zone_duration) => ({
        zone_id: zone_duration[0],
        minutes: zone_duration[1],
        zone_name: ZonesStore.zones()[zone_duration[0]]
      }));
      return watering;
    });
  }
});

module.exports = WateringsStore;
