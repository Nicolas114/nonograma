import React from "react";

class Mode extends React.Component {

    
    render() {
        return (
      <div className="mode">
        <p>Mode: </p>
        <button value="X" onClick={this.props.onClick}>
          X
        </button>
        <button value="#" onClick={this.props.onClick}>
          #
        </button>
      </div>
    );
  }
}

export default Mode;
