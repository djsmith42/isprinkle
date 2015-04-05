var StatusStore = require('../stores/StatusStore');
var React = require('react');

module.exports = React.createClass({
  componentWillMount: function() {
    StatusStore.start();
    StatusStore.on(StatusStore.CHANGE_EVENT, () => {
      this.setState({
        status: StatusStore.status()
      });
    });
  },
  getInitialState: function() {
    return {
      status: null
    }
  },
  render: function() {
    var status = this.state.status;
    if (status) {
      return (
        <div>
          <div>{status.current_action}</div>
        </div>
      )
    } else {
      return (
        <div>
          <div>Loading...</div>
        </div>
      )
    }
  }
});
