import React from "react";

/**
 * Componente Mode - se encarga de renderizar la parte de los modos de pintado de la aplicación.
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
