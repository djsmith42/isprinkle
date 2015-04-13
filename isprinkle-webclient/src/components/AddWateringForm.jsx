var React = require('react');
var ScheduleTypes = require('../constants').ScheduleTypes;
var WateringsStore = require('../stores/WateringsStore');
var ZonesStore = require('../stores/ZonesStore');
require('./AddWateringForm.less');

module.exports = class extends React.Component {
  constructor(props) {
    this.state = {
      isSaving: false,
      scheduleType: ScheduleTypes.EVERY_N_DAYS,
      periodDays: 2,
      startTime: "06:00:00",
      zoneDurations: [
        {id: 1, minutes: 10},
        {id: 2, minutes: 20}
      ]
    }
  }

  componentDidMount() {
    this.formChanged();
  }

  cancelClicked() {
    this.props.onClose();
  }

  saveClicked() {
    var self = this;
    var watering = {
      schedule_type: this.state.scheduleType,
      enabled: true,
      period_days: this.state.periodDays,
      start_time: this.state.startTime,
      zone_durations: this.state.zoneDurations.map((zoneDuration) => (
        [zoneDuration.id, zoneDuration.minutes]
      ))
    };
    WateringsStore.addWatering(watering).then(function() {
      self.props.onClose();
    });
    this.setState({
      isSaving: true
    });
  }

  formChanged(event) {
    this.setState({
      scheduleType: parseInt(this.refs.scheduleType.getDOMNode().value, 10),
      periodDays: parseInt(this.refs.periodDays.getDOMNode().value, 10),
      startTime: this.refs.startTime.getDOMNode().value
    });
  }

  _zones() {
    var i = 1;
    var zoneInfo = ZonesStore.zones();
    var ret = [];
    while (i in zoneInfo) {
      ret.push({
        id: i,
        name: zoneInfo[i]
      });
      i++;
    }
    return ret;
  }

  zoneDurationZoneIdChanged(zoneDuration, event) {
    zoneDuration.id = parseInt(event.target.value, 10);
  }

  zoneDurationMinutesChanged(zoneDuration, event) {
    zoneDuration.minutes = parseInt(event.target.value, 10);
  }

  addZoneClicked() {
    this.state.zoneDurations.push({
      id: 1,
      minutes: 10
    });
    this.setState({
      zoneDurations: this.state.zoneDurations
    });
  }

  render() {
    var isSaving = this.state.isSaving;
    return (
      <form className="AddWateringForm">
        <h4>New Watering:</h4>
        <div className="form-group">
          <label>Schedule Type:</label>
          <select disabled={isSaving} ref="scheduleType" defaultValue={this.state.scheduleType} onChange={this.formChanged.bind(this)} className="form-control">
            <option value={ScheduleTypes.EVERY_N_DAYS}>Every N days</option>
            <option value={ScheduleTypes.FIXED_DAYS_OF_WEEK}>Specific days of the week</option>
            <option value={ScheduleTypes.SINGLE_SHOT}>Single shot</option>
          </select>
        </div>
        {this.state.scheduleType == ScheduleTypes.EVERY_N_DAYS &&
          <div className="form-group">
            <label>Period:</label>
            <input type="number" ref="periodDays" defaultValue={this.state.periodDays} onChange={this.formChanged.bind(this)} className="form-control" />
          </div>
        }
        <div className="form-group">
          <label>Start Time of Day:</label>
          <input type="text" ref="startTime" defaultValue={this.state.startTime} onChange={this.formChanged.bind(this)} className="form-control" />
        </div>
        <div className="form-group">
          <label>Zone Durations:</label>
          {this.state.zoneDurations.map((zoneDuration, index) => (
            <div key={index} className="zone-duration">
              <select className="form-control" onChange={this.zoneDurationZoneIdChanged.bind(this, zoneDuration)} defaultValue={zoneDuration.id}>
                {this._zones().map((zone) => (
                  <option key={zone.id} value={zone.id}>{zone.name}</option>
                ))}
              </select>
              <input type="number" className="form-control" onChange={this.zoneDurationMinutesChanged.bind(this, zoneDuration)} defaultValue={zoneDuration.minutes} />
            </div>
          ))}
        </div>
        <div className="form-group">
          <button type="button" className="btn btn-default" onClick={this.addZoneClicked.bind(this)}>Add Zone</button>
        </div>
        <div>
          <button disabled={isSaving} type="button" className="btn btn-default" onClick={this.cancelClicked.bind(this)}>Cancel</button>
          <button disabled={isSaving} type="button" className="btn btn-primary" onClick={this.saveClicked.bind(this)}>Save</button>
        </div>
      </form>
    )
  }
}

