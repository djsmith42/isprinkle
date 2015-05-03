var StatusStore = require('../stores/StatusStore');
var React = require('react');
var Spinner = require('react-spinkit');
var moment = require('moment');

require('./DeferralStatus.less');

module.exports = class DeferralStatus extends React.Component {
  constructor() {
    this.state = {
      editing: false,
      saving: false
    }
  }

  componentDidMount() {
    var self = this;
    StatusStore.on(StatusStore.CHANGE_EVENT, function() {
      self.setState({});
    });
  }

  editClicked() {
    this.setState({editing: true});
  }

  clearClicked() {
    var self = this;
    self.setState({saving: true, editing: false});
    StatusStore.clearDeferralTime().then(function() {
      self.setState({saving: false});
    });
  }

  editCancelClicked() {
    this.setState({editing: false});
  }

  editSaveClicked() {
    var self = this;
    self.setState({editing: false, saving: true});
    var deferralDate = this.refs.deferralDate.getDOMNode().value;
    var deferralTime = this.refs.deferralTime.getDOMNode().value;
    StatusStore.setDeferralTime(deferralDate + " " + deferralTime).then(function() {
      self.setState({saving: false});
    });
  }

  deferTwoDaysClicked() {
    var self = this;
    self.setState({saving: true});
    StatusStore.setDeferralTime(_twoDaysFromNow()).then(function() {
      self.setState({saving: false});
    });
  }

  _defaultDeferralTime() {
    var deferral = StatusStore.status().deferral_datetime;
    if (deferral) {
      return moment(deferral).format("HH:mm:ss");
    } else {
      return "06:00:00";
    }
  }

  _defaultDeferralDate() {
    var deferral = StatusStore.status().deferral_datetime;
    var date = deferral ? deferral : _twoDaysFromNow();
    return moment(date).format("YYYY-MM-DD");
  }

  render() {
    var status = StatusStore.status();
    if (this.state.saving) {
      return (
        <div className="DeferralStatus saving">
          <Spinner spinnerName='three-bounce' noFadeIn />
        </div>
      )
    } else {
      return (
        <div className="DeferralStatus">
          {status.in_deferral_period && 
            <div className="in-deferral">
              <span>In deferral period until {_prettyDateTime(status.deferral_datetime)}</span>
              <button className="btn btn-link" onClick={this.clearClicked.bind(this)}>clear</button>
            </div>}
          <div>
            <button className="btn btn-link" onClick={this.deferTwoDaysClicked.bind(this)}>Defer all Watering for 48 Hours</button>
          </div>
          {this.state.editing
            ? (<div className="editor">
                 <div>
                   <input ref="deferralDate" type="date" defaultValue={this._defaultDeferralDate()} />
                   <input ref="deferralTime" type="time" defaultValue={this._defaultDeferralTime()} />
                   <button className="btn btn-primary" onClick={this.editSaveClicked.bind(this)}>Save</button>
                   <button className="btn btn-default" onClick={this.editCancelClicked.bind(this)}>Cancel</button>
                 </div>
               </div>)
            : (<div>
                 <button className="btn btn-link" onClick={this.editClicked.bind(this)}>Edit Deferral Time</button>
               </div>)}
        </div>
      )
    }
  }
}

function _twoDaysFromNow() {
  var ret = new Date();
  ret.setDate(ret.getDate() + 2);
  return ret;
}

function _prettyDateTime(date) {
  return moment(date).format("dddd, MMMM Do YYYY, h:mm a");
}
