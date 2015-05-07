var React = require('react');
var format = require('string-format');

var Status = require('./Status');
var WateringList = require('./WateringList');
var QuickRun = require('./QuickRun');

var ZonesStore = require('../stores/ZonesStore');
var WateringsStore = require('../stores/WateringsStore');
var StatusStore = require('../stores/StatusStore');
var ErrorStore = require('../stores/ErrorStore');

require('bootstrap/less/bootstrap.less');
require('./MainApp.less');

module.exports = class MainPage extends React.Component {
  constructor() {
    this.state = {
      allStoresLoaded: false
    }
  }

  componentDidMount() {
    var self = this;
    ErrorStore.on(ErrorStore.CHANGE_EVENT, function() {
      self.setState({});
    });
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

  retryClicked() {
    window.location.reload();
  }

  render() {
    var error = ErrorStore.error();
    var ready = this.state.allStoresLoaded;
    return (
      <div className="container">
        <div className="row">
          <div className="col-md-12">
            <h1>iSprinkle</h1>
            {error
              ? (<div className="alert alert-danger connection-error">
                   <div>
                     <a href="#" className="retry" onClick={this.retryClicked}>Retry</a>
                   </div>
                  <div>
                    <strong>Error</strong>
                  </div>
                   <div>
                     {errorToMessage(error)}
                   </div>
                 </div>)
              : ready
                  ? (<div>
                      <QuickRun/>
                      <Status/>
                      <WateringList/>
                    </div>)
                  : (<div>
                      Loading...
                    </div>)
            }
          </div>
        </div>
      </div>
    )
  }
}

function errorToMessage(error) {
  switch (error.status) {
    case 0:
      return "Could not connect to iSprinkle device";
    default: // e.g., 404
      return format("Error from iSprinkle device, code {} on URL {} {}", error.code, error.config.method, error.config.url);
  }
}
