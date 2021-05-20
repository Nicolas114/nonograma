import React from "react";

class Clue extends React.Component {

  render() {
    const painted = this.props.painted;
    const clue = this.props.clue;
    var styles;

    if (painted) {
      styles = {
        background: 'blue',
      }
    }
    else {
      styles = {
        background: null,
      }
    }

    return (
      <div style={styles} className={"clue"}>
        {clue.map((num, i) => (
          <div key={i}>{num}</div>
        ))}
      </div>
    );
  }
}

export default Clue;
