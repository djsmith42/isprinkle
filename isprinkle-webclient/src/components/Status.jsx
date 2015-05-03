var StatusStore = require('../stores/StatusStore');
var WateringsStore = require('../stores/WateringsStore');
var DeferralStatus = require('./DeferralStatus');
var React = require('react');

module.exports = class Status extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      status: null
    }
  }

  render() {
    var status = StatusStore.status();
    var activeZoneName = WateringsStore.activeZoneName();
    if (status) {
      return (
        <div>
          <div>
            Current time: {status.current_time}
          </div>
          {activeZoneName
            ? <div>Status: Watering {activeZoneName}</div>
            : <div>Status: {status.current_action}</div>}
          <DeferralStatus/>
        </div>
      )
    } else {
      return (
        <div>Loading status...</div>
      )
    }
  }
}
