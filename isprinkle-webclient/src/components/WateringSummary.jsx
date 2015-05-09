var React = require('react');
var ScheduleTypes = require('../constants').ScheduleTypes;
require('./WateringSummary.less');

module.exports = class WateringSummary extends React.Component {
  constructor(props) {
  }

  render() {
    return (
      <div className="WateringSummary">
        {this._summary()}
        {this.props.watering.enabled ||
          <span className="disabled"> (disabled)</span>}
      </div>
    )
  }

  _summary() {
    var watering = this.props.watering;
    switch (watering.schedule_type) {
      case ScheduleTypes.EVERY_N_DAYS:
        if (watering.period_days == 1) {
          return <span>Every day at {watering.start_time}</span>
        } else {
          return <span>Every {watering.period_days} days at {watering.start_time}</span>
        }
      case ScheduleTypes.FIXED_DAYS_OF_WEEK:
        return <span>Days of the Week (this doesn't work yet)</span>
      case ScheduleTypes.SINGLE_SHOT:
        return <span>Single Shot at {watering.start_time} on {watering.start_date}</span>
      default:
        return <span>Unknown Watering Type: {watering.schedule_type}</span>
    }
  }
}
