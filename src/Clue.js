import React from "react";

/**
 * Componente Clue - se encarga de renderizar la parte de las pistas de la aplicación.
 */
class Clue extends React.Component {

  render() {
    const painted = this.props.painted; //determina si la pista debe ir pintada o no
    const clue = this.props.clue;
    var styles;
    //manejamos los estilos dependiendo de si la pista debe ir pintada o no
    if (painted) {
      styles = {
        background: '#7CA5B8',
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
