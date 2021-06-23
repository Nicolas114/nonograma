import React from "react";

/**
 * Componente RevealCell - se encarga de renderizar la parte del botón que 'togglea' cuándo revelar la solución correcta a una celda
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
