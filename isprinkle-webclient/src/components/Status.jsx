var StatusStore = require('../stores/StatusStore');
var WateringsStore = require('../stores/WateringsStore');
var React = require('react');

module.exports = class extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      status: null
    }
  }

  componentDidMount() {
    StatusStore.start();
    StatusStore.on(StatusStore.CHANGE_EVENT, () => {
      this.setState({
        status: StatusStore.status()
      });
    });
  }

  render() {
    var status = this.state.status;
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
          {status.in_deferral_period && 
            <div>
              In deferral period until {status.deferral_datetime}
            </div>}
        </div>
      )
    } else {
      return (
        <div>Loading status...</div>
      )
    }
  }
}
