import React from "react";

class Level extends React.Component {
    render() {
      return (

      <div className="level">
        <button onClick={this.props.onClick}>Load Another Level</button>
      </div>
    );
  }
}

export default Level;
