var React = require('react');
var Status = require('./Status');
var WateringList = require('./WateringList');

var ZonesStore = require('../stores/Zones');
var WateringsStore = require('../stores/Waterings');
var StatusStore = require('../stores/StatusStore');

require('bootstrap/less/bootstrap.less');
require('./MainApp.less');

module.exports = class extends React.Component {
  constructor() {
    this.state = {
      allStoresLoaded: false
    }
  }

  componentDidMount() {
    var self = this;
    console.log("Loading stores..");
    Promise.all([
      ZonesStore.fetch(),
      StatusStore.start(),
      WateringsStore.start()
    ]).then(function() {
      console.log("All stores loaded");
      self.setState({
        allStoresLoaded: true
      });
    });;
  }

  render() {
    var ready = this.state.allStoresLoaded;
    return (
      <div>
        <h1>iSprinkle</h1>
        {ready
          ? (<div>
              <Status />
              <WateringList />
            </div>)
          : (<div>
              Loading...
             </div>)}
      </div>
    )
  }
}
