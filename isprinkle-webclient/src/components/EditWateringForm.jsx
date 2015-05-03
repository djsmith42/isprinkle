var React = require('react');
var WateringForm = require('./WateringForm');

class EditWateringForm extends React.Component {
  constructor(props) {
    this.props = props
  }

  render() {
    return (
      <WateringForm onClose={this.props.onClose} mode="edit" wateringToEdit={this.props.wateringToEdit} />
    )
  }
}

EditWateringForm.propTypes = {
  onClose: React.PropTypes.func.isRequired,
  wateringToEdit: React.PropTypes.object.isRequired
}

module.exports = EditWateringForm
