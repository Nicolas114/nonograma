import React from "react";

/**
 * Componente RevealSolution - se encarga de renderizar la parte del botón de revelar el tablero solucionado por completo.
 */
class RevealSolution extends React.Component {

    render() {
      return (
      <div className="reveal_solution">
        <button id="reveal_solution_button" className="reveal_solution_button" value="reveal" onClick={this.props.onClick}>
          Reveal Solution
        </button>
      </div>
    );
  }
}

export default RevealSolution;
