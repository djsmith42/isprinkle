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
    return ReactAddons.classSet({
      'Watering': true,
      'active': watering.is_active
    });
  }

  _zoneDurationClasses(zone_duration) {
    return ReactAddons.classSet({
      'row': true,
      'zone-duration': true,
      'active': zone_duration.is_active
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
                <div className={this._zoneDurationClasses(zone_duration)}>
                  <div className="name col-sm-12 col-md-2">
                    {zone_duration.zone_name}
                  </div>
                  <div className="minutes col-sm-12 col-md-3">
                    {zone_duration.minutes} minutes
                    {zone_duration.is_active &&
                      <span> (watering now)</span>}
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
