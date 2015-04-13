var React = require('react');
var ScheduleTypes = require('../constants').ScheduleTypes;
var WateringsStore = require('../stores/WateringsStore');

module.exports = class extends React.Component {
  constructor(props) {
    this.state = {
      isSaving: false
    }
  }

  componentDidMount() {
  }

  cancelClicked() {
    this.props.onClose();
  }

  saveClicked() {
    // FIXME Disable button while saving
    // FIXME Use real values:
    var self = this;
    var watering = {
      schedule_type: parseInt(this.refs.scheduleType.getDOMNode().value, 10),
      enabled: true,
      period_days: 3,
      start_time: '00:04:30',
      zone_durations: [[
        3, 10
      ],[
        1, 20
      ],[
        2, 30
      ]]
    };
    WateringsStore.addWatering(watering).then(function() {
      self.props.onClose();
    });
    this.setState({
      isSaving: true
    });
  }

  formChanged(event) {
    console.log("formChanged()", event.target.value, this.refs.foo);//.scheduleType.getDOMNode().value);
  }

  render() {
    var isSaving = this.state.isSaving;
    return (
      <div>
        <h4>New Watering:</h4>
        <div>
          <select disabled={isSaving} ref="scheduleType" onChange={this.formChanged}>
            <option ref="foo" value={ScheduleTypes.EVERY_N_DAYS}>Every N days</option>
            <option value={ScheduleTypes.FIXED_DAYS_OF_WEEK}>Specific days of the week</option>
            <option value={ScheduleTypes.SINGLE_SHOT}>Single shot</option>
          </select>
        </div>
        <div>
          <button disabled={isSaving} className="btn btn-default" onClick={this.cancelClicked.bind(this)}>Cancel</button>
          <button disabled={isSaving} className="btn btn-primary" onClick={this.saveClicked.bind(this)}>Save</button>
        </div>
      </div>
    )
  }
}

