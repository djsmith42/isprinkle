var WateringsStore = require('../stores/Waterings');
var React = require('react');

module.exports = class extends React.Component {
  constructor(props) {
    this.state = {
      loading: true,
    }
  }

  componentDidMount() {
    WateringsStore.start();
    WateringsStore.on(WateringsStore.CHANGE_EVENT, () => {
      var waterings = WateringsStore.waterings();
      this.setState({
        loading: waterings === null,
        waterings: waterings
      });
    });
  }

  render() {
    var waterings = this.state.waterings;
    if (!this.state.loading) {
      return (
        <div>
          <h2>Watering Schedule:</h2>
          {waterings.map((watering) => (
            <div>
              <div>{watering.uuid}</div>
              <ul>
                {watering.zone_durations.map((zone_duration) => (
                  <li>{zone_duration.zone_name} for {zone_duration.minutes} minutes</li>
                  ))}
              </ul>
            </div>
            ))}
        </div>
      )
    } else {
      return <div>Loading waterings...</div>
    }
  }
}
