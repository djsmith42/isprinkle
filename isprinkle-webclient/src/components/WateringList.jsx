var WateringsStore = require('../stores/WateringsStore');
var ReactAddons = require('react-addons');
var React = require('react');
var Spinner = require('react-spinkit');

var WateringSummary = require('./WateringSummary');
var AddWateringForm = require('./AddWateringForm');
var EditWateringForm = require('./EditWateringForm');

require('./WateringList.less');

module.exports = class WateringList extends React.Component {
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
      watering.is_pending_change = true;
      self.setState({}); // re-render to pick up is_pending_change
      WateringsStore.deleteWatering(watering);
    }
  }

  disableWateringClicked(watering) {
    var self = this;
    watering.is_pending_change = true;
    self.setState({}); // re-render to pick up is_pending_change
    WateringsStore.disableWatering(watering).then(function() {
      delete watering.is_pending_change;
      self.setState({}); // re-render to pick up is_pending_change
    });
  }

  runNowClicked(watering) {
    var self = this;
    watering.is_pending_change = true;
    self.setState({}); // re-render to pick up is_pending_change
    WateringsStore.runNow(watering).then(function() {
      delete watering.is_pending_change;
      self.setState({}); // re-render to pick up is_pending_change
    });
  }

  enableWateringClicked(watering) {
    var self = this;
    watering.is_pending_change = true;
    self.setState({}); // re-render to pick up is_pending_change
    WateringsStore.enableWatering(watering).then(function() {
      delete watering.is_pending_change;
      self.setState({}); // re-render to pick up is_pending_change
    });
  }

  addWateringFormClosed() {
    this.setState({
      showAddWateringForm: false
    });
  }

  editClicked(watering) {
    this.setState({
      wateringToEdit: watering
    });
  }

  editFormClosed() {
    this.setState({
      wateringToEdit: undefined
    });
  }

  _wateringClasses(watering) {
    return ReactAddons.classSet({
      'Watering': true,
      'active': watering.is_active,
      'disabled': !watering.enabled
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
    var wateringToEdit = this.state.wateringToEdit;
    if (waterings !== null) {
      return (
        <div className="WateringList">
          <h4>Watering Schedule:</h4>
          {waterings.map((watering) => (
            <div key={watering.uuid} className={this._wateringClasses(watering)}>
              {wateringToEdit && wateringToEdit.uuid === watering.uuid
                ? <EditWateringForm
                     wateringToEdit={watering}
                     onClose={this.editFormClosed.bind(this)}
                   />
                : <div>
                    <button
                      className="btn btn-danger delete pull-right"
                      disabled={watering.is_pending_change}
                      onClick={this.deleteWateringClicked.bind(this, watering)}>
                      Delete
                    </button>
                    {watering.enabled
                      ? <button
                          className="btn btn-warning disable pull-right"
                          disabled={watering.is_pending_change}
                          onClick={this.disableWateringClicked.bind(this, watering)}>
                          Disable
                        </button>
                      : <button
                          className="btn btn-warning enable pull-right"
                          disabled={watering.is_pending_change}
                          onClick={this.enableWateringClicked.bind(this, watering)}>
                          Enable
                        </button>}
                    <button
                      className="btn btn-primary run-now pull-right"
                      disabled={watering.is_pending_change}
                      onClick={this.runNowClicked.bind(this, watering)}>
                      Run Now
                    </button>
                    <button
                      className="btn btn-info edit pull-right"
                      onClick={this.editClicked.bind(this, watering)}>
                      Edit
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
                      </div>))}
                  </div>}
                </div>))}
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
      return (
        <div className="WateringListLoading">
          <Spinner spinnerName='three-bounce' noFadeIn />
        </div>
      )
    }
  }
}
