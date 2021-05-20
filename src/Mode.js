import React from "react";

class Mode extends React.Component {

    
    render() {

      return (

      <div className="mode">
        <p>Mode: </p>
        <button className="mode__button--skip" style={{}} value="X" onClick={this.props.onClick}>
          X
        </button>
        <button className="mode__button--paint" style={{background: 'blue'}} value="#" onClick={this.props.onClick}>
          #
        </button>
      </div>
    );
  }
}

export default Mode;
