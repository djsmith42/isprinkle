var React = require('react');
var Status = require('./Status');

module.exports = React.createClass({
    render: function(){
      return (
        <div>
          <h1>Main App</h1>
          <Status />
        </div>
      )
    }
});
