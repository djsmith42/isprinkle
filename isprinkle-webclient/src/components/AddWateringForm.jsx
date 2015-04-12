//var WateringsStore = require('../stores/WateringsStore');
var React = require('react');
var ScheduleTypes = require('../constants').ScheduleTypes;

module.exports = class extends React.Component {
  constructor(props) {
    this.state = {
      show: false
    }
  }

  componentDidMount() {
  }

  cancelClicked() {
    this.props.onClose();
  }

  saveClicked() {
    // TODO Save new watering and then close
    this.props.onClose();
  }

  render() {
    return (
      <div>
        <h4>New Watering:</h4>
        <div>
          <select>
            <option value={ScheduleTypes.EVERY_N_DAYS}>Every N days</option>
            <option value={ScheduleTypes.FIXED_DAYS_OF_WEEK}>Specific days of the week</option>
            <option value={ScheduleTypes.SINGLE_SHOT}>Single shot</option>
          </select>
        </div>
        <button className="btn btn-default" onClick={this.cancelClicked.bind(this)}>Cancel</button>
        <button className="btn btn-primary" onClick={this.saveClicked.bind(this)}>Save</button>
      </div>
    )
  }
}

