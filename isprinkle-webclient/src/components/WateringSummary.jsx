var React = require('react');
var ScheduleTypes = require('../constants').ScheduleTypes;
require('./WateringSummary.less');

module.exports = class extends React.Component {
  constructor(props) {
  }

  render() {
    return (
      <div>
        <div className="WateringSummary">
          {this._summary()}
        </div>
        {this.props.watering.enabled ||
          <div>(disabled)</div>}
      </div>
    )
  }

  _summary() {
    var watering = this.props.watering;
    switch (watering.schedule_type) {
      case ScheduleTypes.EVERY_N_DAYS:
        if (watering.period_days == 1) {
          return <div>Every day at {watering.start_time}</div>
        } else {
          return <div>Every {watering.period_days} days at {watering.start_time}</div>
        }
      case ScheduleTypes.FIXED_DAYS_OF_WEEK:
        return <div>Days of the Week</div>
      case ScheduleTypes.SINGLE_SHOT:
        return <div>Single Shot</div>
      default:
        return <div>Unknown Watering Type: {watering.schedule_type}</div>
    }
  }
}
