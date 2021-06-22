import React from "react";

/**
 * Componente Mode - se encarga de renderizar la parte de los modos de pintado de la aplicación.
 */
class RevealCell extends React.Component {

    render() {
      return (
      <div className="reveal_cell">
        <button id="reveal_cell_button" className="reveal_cell_button" value="reveal" onClick={this.props.onClick}>
          Reveal Cell
        </button>
      </div>
    );
  }
}

export default RevealCell;
