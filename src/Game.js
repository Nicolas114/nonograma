import React from "react";
import PengineClient from "./PengineClient";
import Board from "./Board";
import Mode from "./Mode";

class Game extends React.Component {
  pengine;

  constructor(props) {
    super(props);
    this.state = {
      grid: null,
      mode: "#",
      rowClues: null,
      colClues: null,
      waiting: false,
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  handlePengineCreate() {
    const queryS = "init(PistasFilas, PistasColumnas, Grilla)";
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response["Grilla"],
          rowClues: response["PistasFilas"],
          colClues: response["PistasColumnas"],
        });
      }
    });
  }

  handleClick(i, j) {
    // convierte el arreglo de pistasfila y pistascolumna a la representacion correcta para prolog (ver console.log())
    var rowClues = "[";
    for (let i = 0; i < this.state.rowClues.length; i++) {
      rowClues += "[" + this.state.rowClues[i] + "]";
      if (i !== this.state.rowClues.length - 1) {
        rowClues += ", ";
      }
    }
    rowClues += "]";

    var colClues = "[";
    for (let i = 0; i < this.state.colClues.length; i++) {
      colClues += "[" + this.state.colClues[i] + "]";
      if (i !== this.state.colClues.length - 1) {
        colClues += ", ";
      }
    }
    colClues += "]";

    // No action on click if we are waiting.
    if (this.state.waiting) {
      return;
    }

    // Build Prolog query to make the move, which will look as follows:
    // put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const queryS =
      'put("' +
      this.state.mode +
      '", [' +
      i +
      "," +
      j +
      "], " +
      rowClues +
      ", " +
      colClues +
      ", " +
      squaresS +
      ", GrillaRes, FilaSat, ColSat)";
    console.log(queryS);
    this.setState({
      waiting: true,
    });
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          //falta agregar toda la parte de las PistasFilas, PistasColumnas, etc
          grid: response["GrillaRes"],

          waiting: false,
        });

        const rowSatisfied = response["FilaSat"];
        const colSatisfied = response["ColSat"];
        const rowClueToPaint = document.getElementsByClassName("rowClues")[0].childNodes[i];
        const colClueToPaint = document.getElementsByClassName("colClues")[0].childNodes[j+1];

        //pinta la pista que se está cumpliendo
        if (rowSatisfied) {
          rowClueToPaint.style = "background: gray";
        } else {
          rowClueToPaint.style = "background: null";
        }
        console.log(colClueToPaint);
        if (colSatisfied) {
          colClueToPaint.style = "background: gray";
        }
        else {
          colClueToPaint.style = "background: null";
        }
      } else {
        this.setState({
          waiting: false,
        });
      }
    });
  }

  render() {
    if (this.state.grid === null) {
      return null;
    }
    const statusText = "";
    return (
      <div className="game">
        <Board
          grid={this.state.grid}
          rowClues={this.state.rowClues}
          colClues={this.state.colClues}
          onClick={(i, j) => this.handleClick(i, j)}
        />
        <div className="gameInfo">{statusText}</div>
        <Mode onClick={(e) => this.handleModeClick(e)} />
      </div>
    );
  }

  handleModeClick(e) {
    const divmode = e.target.parentElement;
    const clickedButton = e.currentTarget;

    this.setState({
      mode: e.target.value,
    });
    if (clickedButton.value === "#") {
      divmode.children[2].style = "background: blue";
      divmode.children[1].style = "background: null";
    } else {
      divmode.children[2].style = "background: null";
      divmode.children[1].style = "background: blue";
    }
  }
}

export default Game;
