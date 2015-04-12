var WateringsStore = require('../stores/WateringsStore');
var ReactAddons = require('react-addons');
var React = require('react');
var WateringSummary = require('./WateringSummary');

require('./WateringList.less');

module.exports = class extends React.Component {
  constructor(props) {
    this.state = {
      waterings: null
    }
  }

  componentDidMount() {
    WateringsStore.on(WateringsStore.CHANGE_EVENT, () => {
      this.setState({
        waterings: WateringsStore.waterings()
      });
    });
  }

  _classes(watering) {
    console.log("watering.is_active:", watering.is_active);
    return ReactAddons.classSet({
      'Watering': true,
      'active': watering.is_active
    });
  }

  render() {
    var waterings = this.state.waterings;
    if (waterings !== null) {
      return (
        <div className="WateringList">
          <h4>Watering Schedule:</h4>
          {waterings.map((watering) => (
            <div className={this._classes(watering)}>
              <WateringSummary watering={watering} />
              {watering.zone_durations.map((zone_duration) => (
                <div className="row">
                  <div className="zone-name col-sm-12 col-md-2">
                    {zone_duration.zone_name}
                  </div>
                  <div className="zone-duration col-sm-12 col-md-2">
                    {zone_duration.minutes} minutes
                  </div>
                </div>
              ))}
            </div>
            ))}
        </div>
      )
    } else {
      return <div>Loading waterings...</div>
    }
  }
}
