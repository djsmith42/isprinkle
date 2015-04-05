var React = require('react');
var Status = require('./Status');

module.exports = class extends React.Component {
  render() {
    return (
      <div>
        <h1>iSprinkle</h1>
        <Status />
      </div>
    )
  }
}
