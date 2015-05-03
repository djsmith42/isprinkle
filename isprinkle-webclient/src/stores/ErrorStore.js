var assign = require('object-assign');
var EventEmitter = require('events').EventEmitter;

module.exports = assign({}, EventEmitter.prototype, {
  CHANGE_EVENT: '__change__',
  setError: function(errorMsg) {
    this._errorMsg = errorMsg;
    this.emit(this.CHANGE_EVENT);
  },
  error: function() {
    return this._errorMsg;
  }
});
