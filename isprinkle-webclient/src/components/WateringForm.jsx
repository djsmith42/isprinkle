var React = require('react');
var ScheduleTypes = require('../constants').ScheduleTypes;
var WateringsStore = require('../stores/WateringsStore');
var ZonesStore = require('../stores/ZonesStore');

require('./WateringForm.less');

class WateringForm extends React.Component {
  constructor(props) {
    this.props = props;
    switch (this.props.mode) {
      case "add":
        this.state = {
          scheduleType  : ScheduleTypes.EVERY_N_DAYS,
          periodDays    : 2,
          startDate     : "2015-01-01",
          startTime     : "06:00:00",
          zoneDurations : [
            {id: 1, minutes: 10},
            {id: 2, minutes: 20}
          ]
        }
        break;
      case "edit":
        var wateringToEdit = this.props.wateringToEdit;
        this.state = {
          uuid          : wateringToEdit.uuid,
          scheduleType  : wateringToEdit.schedule_type,
          periodDays    : wateringToEdit.period_days,
          startDate     : wateringToEdit.start_date,
          startTime     : wateringToEdit.start_time,
          zoneDurations : wateringToEdit.zone_durations.map((zone_duration) => ({
            id      : zone_duration.zone_id,
            minutes : zone_duration.minutes
          }))
        }
        break;
      default:
        throw new Error("Invalid mode: " + this.props.mode);
    }
    this.state.isSaving = false;
  }

  componentDidMount() {
    this.formChanged();
  }

  formChanged(event) {
    this.setState({
      scheduleType: parseInt(this.refs.scheduleType.getDOMNode().value, 10),
      startTime: this.refs.startTime.getDOMNode().value
    });

    if (this.refs.periodDays) {
      this.setState({
        periodDays: parseInt(this.refs.periodDays.getDOMNode().value, 10)
      });
    }

    if (this.refs.startDate) {
      this.setState({
        startDate: this.refs.startDate.getDOMNode().value
      });
    }
  }

  saveClicked() {
    var self = this;
    var watering = {
      schedule_type: this.state.scheduleType,
      enabled: true,
      period_days: this.state.periodDays,
      start_date: this.state.startDate,
      start_time: this.state.startTime,
      zone_durations: this.state.zoneDurations.map((zoneDuration) => (
        [zoneDuration.id, zoneDuration.minutes]
      ))
    };
    switch (this.props.mode) {
      case "add":
        WateringsStore.addWatering(watering).then(function() {
          self.props.onClose();
        });
        break;
      case "edit":
        watering.uuid = this.state.uuid;
        WateringsStore.updateWatering(watering).then(function() {
          self.props.onClose();
        });
        break;
    }
    this.setState({
      isSaving: true
    });
  }

  cancelClicked() {
    this.props.onClose();
  }

  _zones() {
    return ZonesStore.zoneList();
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

  removeZoneDurationClicked(index) {
    this.state.zoneDurations.splice(index, 1);
    this.setState({
      zoneDurations: this.state.zoneDurations
    })
  }

  preventSubmit(e) {
    e.preventDefault()
  }

  render() {
    var isSaving = this.state.isSavig;
    return (
      <form className="WateringForm" onSubmit={this.preventSubmit}>
        {this.props.mode === "edit" && <h4>Edit Watering:</h4>}
        {this.props.mode === "add"  && <h4>New Watering: </h4>}
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
          </div>}
        {this.state.scheduleType == ScheduleTypes.SINGLE_SHOT &&
          <div className="form-group">
            <label>Start Date:</label>
            <input type="text" ref="startDate" defaultValue={this.state.startDate} onChange={this.formChanged.bind(this)} className="form-control" />
          </div>}
        <div className="form-group">
          <label>Start Time of Day:</label>
          <input type="text" ref="startTime" defaultValue={this.state.startTime} onChange={this.formChanged.bind(this)} className="form-control" />
        </div>
        <div className="form-group">
          <label>Scheduled Zones:</label>
          {this.state.zoneDurations.map((zoneDuration, index) => (
            <div key={index + "-" + zoneDuration.id + "-" + zoneDuration.minutes} className="zone-duration">
              <button onClick={this.removeZoneDurationClicked.bind(this, index)} className="remove-zone">x</button>
              <select className="form-control zone-select" onChange={this.zoneDurationZoneIdChanged.bind(this, zoneDuration)} defaultValue={zoneDuration.id}>
                {this._zones().map((zone) => (
                  <option key={zone.id} value={zone.id}>{zone.name}</option>
                ))}
              </select>
              <input
                type="number"
                className="form-control zone-minutes"
                onChange={this.zoneDurationMinutesChanged.bind(this, zoneDuration)}
                defaultValue={zoneDuration.minutes} />
              <div className="minutes">Minutes</div>
              <div className="clearfix"></div>
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

WateringForm.propTypes = {
  mode    : React.PropTypes.oneOf(['add', 'edit']).isRequired,
  onClose : React.PropTypes.func.isRequired
};

module.exports = WateringForm
