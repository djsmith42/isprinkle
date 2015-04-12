var WateringsStore = require('../stores/Waterings');
var React = require('react');
var WateringSummary = require('./WateringSummary');

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
              <WateringSummary watering={watering} />
              <table>
                {watering.zone_durations.map((zone_duration) => (
                  <tr>
                    <td>{zone_duration.zone_name}</td>
                    <td>{zone_duration.minutes} minutes</td>
                  </tr>
                ))}
              </table>
            </div>
            ))}
        </div>
      )
    } else {
      return <div>Loading waterings...</div>
    }
  }
}
