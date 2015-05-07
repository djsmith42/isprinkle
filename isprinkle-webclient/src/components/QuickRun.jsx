var React = require('react');
var ZonesStore = require('../stores/ZonesStore');
var WateringsStore = require('../stores/WateringsStore');

require('./QuickRun.less');

module.exports = class QuickRun extends React.Component {
  constructor() {
    this.state = {
      durationMinutes: 10,
      showDrawer: false
    }
  }

  openClicked() {
    this.setState({
      showDrawer: !this.state.showDrawer
    });
  }

  zoneClicked(zoneId) {
    WateringsStore.quickRun(zoneId, this.state.durationMinutes);
    this.setState({
      showDrawer: false
    });
  }

  durationChanged() {
    this.setState({
      durationMinutes: parseInt(this.refs.duration.getDOMNode().value, 10)
    });
  }

  render() {
    var zones = ZonesStore.zoneList();
    return (
      <div className="QuickRun">
        <button className="btn btn-primary" onClick={this.openClicked.bind(this)}>Quick Run</button>
        {this.state.showDrawer &&
          <div className="drawer">
            Duration: <input ref="duration" type="number" defaultValue={this.state.durationMinutes} onChange={this.durationChanged.bind(this)} /> minutes
            {zones.map((zone) => (
              <div key={zone.id}>
                <a href="#" onClick={this.zoneClicked.bind(this, zone.id)}>{zone.name}</a>
              </div>
              ))}
            </div>}
          </div>)
  }
}
