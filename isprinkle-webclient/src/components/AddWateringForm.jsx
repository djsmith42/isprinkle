var React = require('react');
var WateringForm = require('./WateringForm');

class AddWateringForm extends React.Component {
  constructor(props) {}

  render() {
    return (
      <WateringForm onClose={this.props.onClose} mode="add" />
    )
  }
}

AddWateringForm.propTypes = {
  onClose: React.PropTypes.func.isRequired
}

module.exports = AddWateringForm
