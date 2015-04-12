var api = require('../api');
var assign = require('object-assign');
var EventEmitter = require('events').EventEmitter;
var ZonesStore = require('./Zones');
var StatusStore = require('./StatusStore');
var clone = require('clone');

var WateringsStore = assign({}, EventEmitter.prototype, {
  CHANGE_EVENT: '__change__',
  start: function() {
    this._waterings = null;
    var self = this;
    ZonesStore.on(ZonesStore.CHANGE_EVENT, () => {
      self._massage();
      this.emit(this.CHANGE_EVENT);
    });
    StatusStore.on(StatusStore.CHANGE_EVENT, () => {
      self._massage();
      this.emit(this.CHANGE_EVENT);
    });
    return this._fetchLoop();
  },
  fetch: function() {
    return api.get('/waterings').then((waterings) => {
      this._download = waterings;
      this._massage();
      this.emit(this.CHANGE_EVENT);
    });
  },
  waterings: function() {
    return this._waterings;
  },
  _fetchLoop: function() {
    return this.fetch().then(() => {
      setTimeout(this._fetchLoop.bind(this), 3000);
    });
  },
  _massage: function() {
    var status = StatusStore.status();
    if (status && this._download) {
      var status = StatusStore.status();
      var activeWateringId = (status && status.active_watering);
      this._waterings = this._download.map((watering) => {
        var watering = clone(watering)
        watering.is_active = !!(activeWateringId && activeWateringId == watering.uuid);
        watering.zone_durations = watering.zone_durations.map((zone_duration) => ({
          zone_id: zone_duration[0],
          minutes: zone_duration[1],
          zone_name: ZonesStore.zones()[zone_duration[0]]
        }));
        return watering;
      });
    } else {
      this._waterings = null;
    }
  }
});

module.exports = WateringsStore;
