var StatusStore = require('../stores/StatusStore');
var React = require('react');

setInterval(function() {
  StatusStore.fetch();
}, 1000);

module.exports = React.createClass({
  render: () => (
    <h2>Status Component</h2>
  )
});
