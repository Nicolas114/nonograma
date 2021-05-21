import React from "react";

class Mode extends React.Component {

    
    render() {

      return (

      <div className="mode">
        <p>Mode: </p>
        <button className="mode__button--skip" style={{background: 'tan'}} value="X" onClick={this.props.onClick}>
          X
        </button>
        <button className="mode__button--paint" style={{border: '2px solid red', background: '#020122'}} value="#" onClick={this.props.onClick}>
          #
        </button>
      </div>
    );
  }
}

export default Mode;
