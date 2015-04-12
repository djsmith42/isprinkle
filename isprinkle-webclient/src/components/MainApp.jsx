var React = require('react');
var Status = require('./Status');
var WateringList = require('./WateringList');

var ZonesStore = require('../stores/ZonesStore');
var WateringsStore = require('../stores/WateringsStore');
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
    Promise.all([
      ZonesStore.fetch(),
      StatusStore.start(),
      WateringsStore.start()
    ]).then(function() {
      self.setState({
        allStoresLoaded: true
      });
    });;
  }

  render() {
    var ready = this.state.allStoresLoaded;
    return (
      <div className="container">
        <div className="row">
          <div className="col-md-12">
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
        </div>
      </div>
    )
  }
}
