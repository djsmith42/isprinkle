var api = require('../api');
var assign = require('object-assign');
var EventEmitter = require('events').EventEmitter;
var ZonesStore = require('./ZonesStore');
var StatusStore = require('./StatusStore');
var clone = require('clone');

var WateringsStore = assign({}, EventEmitter.prototype, {
  CHANGE_EVENT: '__change__',
  addWatering: function(watering) {
    var self = this;
    return new Promise((resolve, reject) => {
      api.post('/add-watering', watering).then(function() {
        self.fetch().then(function() {
          resolve();
        });
      });
    });
  },
  activeZoneName: function(uuid) {
    var status = StatusStore.status();
    var active_watering_uuid = status.active_watering;
    var active_index = status.active_index;
    if (active_watering_uuid && active_index !== undefined && active_index !== null) {
      for (var i=0; i<this._waterings.length; i++) {
        if (this._waterings[i].uuid == active_watering_uuid) {
          var watering = this._waterings[i];
          for (var j=0; j<watering.zone_durations.length; j++) {
            if (j == active_index) {
              var zone_duration = watering.zone_durations[j];
              return zone_duration.zone_name;
            }
          }
        }
      }
    }
  },
  runNow: function(watering) {
    var self = this;
    return new Promise((resolve, reject) => {
      api.post('/run-watering-now', watering.uuid).then(function() {
        self.fetch().then(function() {
          resolve();
        });
      });
    });
  },
  deleteWatering: function(watering) {
    var self = this;
    return new Promise((resolve, reject) => {
      api.post('/delete-watering', watering.uuid).then(function() {
        self.fetch().then(function() {
          resolve();
        });
      });
    });
  },
  disableWatering: function(watering) {
    var self = this;
    return new Promise((resolve, reject) => {
      api.post('/disable-watering', watering.uuid).then(function() {
        self.fetch().then(function() {
          resolve();
        });
      });
    });
  },
  enableWatering: function(watering) {
    var self = this;
    return new Promise((resolve, reject) => {
      api.post('/enable-watering', watering.uuid).then(function() {
        self.fetch().then(function() {
          resolve();
        });
      });
    });
  },
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
      var activeIndex = (status && status.active_index);
      this._waterings = this._download.map((watering) => {
        var watering = clone(watering)
        watering.is_active = !!(activeWateringId && activeWateringId === watering.uuid);
        watering.zone_durations = watering.zone_durations.map((zone_duration, index) => ({
          zone_id: zone_duration[0],
          minutes: zone_duration[1],
          zone_name: ZonesStore.zones()[zone_duration[0]],
          is_active: !!(activeWateringId && activeWateringId === watering.uuid && activeIndex === index)
        }));
        return watering;
      });
    } else {
      this._waterings = null;
    }
  }
});

module.exports = WateringsStore;
