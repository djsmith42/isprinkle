var WateringsStore = require('../stores/WateringsStore');
var ReactAddons = require('react-addons');
var React = require('react');
var WateringSummary = require('./WateringSummary');
var AddWateringForm = require('./AddWateringForm');

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

  addWateringClicked() {
    this.setState({
      showAddWateringForm: true
    });
  }

  deleteWateringClicked(watering) {
    var self = this;
    if (confirm("Delete this watering?")) {
      watering.is_pending_delete = true;
      self.setState({}); // re-render to pick up is_pending_delete
      WateringsStore.deleteWatering(watering);
    }
  }

  addWateringFormClosed() {
    this.setState({
      showAddWateringForm: false
    });
  }

  _wateringClasses(watering) {
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
            <div key={watering.uuid} className={this._wateringClasses(watering)}>
              <button
                className="btn btn-danger delete pull-right"
                disabled={watering.is_pending_delete}
                onClick={this.deleteWateringClicked.bind(this, watering)}>
                Delete
              </button>
              <WateringSummary watering={watering} />
              {watering.zone_durations.map((zone_duration, index) => (
                <div key={index} className={this._zoneDurationClasses(zone_duration)}>
                  <div className="spacer col-md-1 col-sm-0"> </div>
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
            {this.state.showAddWateringForm
              ? <AddWateringForm onClose={this.addWateringFormClosed.bind(this)} />
              : <div className="add-watering-button">
                  <button className="btn btn-primary" onClick={this.addWateringClicked.bind(this)}>
                    Add Watering
                  </button>
                </div>}
        </div>
      )
    } else {
      return <div>Loading waterings...</div>
    }
  }
}
