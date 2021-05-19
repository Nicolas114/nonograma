import React from "react";
import PengineClient from "./PengineClient";
import Board from "./Board";
import Mode from "./Mode";
import Level from "./Level";

class Game extends React.Component {
  pengine;

  constructor(props) {
    super(props);
    this.state = {
      grid: null,
      mode: "#",
      rowClues: null,
      satisfiedRowClues: [],
      colClues: null,
      satisfiedColClues: [],
      waiting: false,
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  handlePengineCreate() {
    var queryS = "init(PistasFilas, PistasColumnas, Grilla)";
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response["Grilla"],
          rowClues: response["PistasFilas"],
          colClues: response["PistasColumnas"],
        });
        this.checkeo_inicial()
      }
    });


  }

  checkeo_inicial(){

    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);
    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_");

    const queryS = "checkeo_inicial(" + rowClues + ", " + colClues + ", " + squaresS + ", ResultadosFilas, ResultadosColumnas)";
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          satisfiedRowClues: response["ResultadosFilas"],
        });
      }
    });
  }

  handleRowCluesStates() {
    let rowStates = [];

    //modificar luego porque debe acomodarse al checkeo inicial (es decir, si ya hay pistas satisfechas)
    for (let i = 0; i < this.state.rowClues.length; i++) {
      rowStates[i] = false;
    }

    this.setState({
      satisfiedRowClues: rowStates,
    });
  }

  loadLevel(number) {
    this.pengine.next((success, response) => {
      if (success) {
        console.log(response);
        this.setState({
          grid: response["Grilla"],
          rowClues: response["PistasFilas"],
          colClues: response["PistasColumnas"],
        });
      }
    });
  }

  handleClick(i, j) {
    // No action on click if we are waiting.
    if (this.state.waiting) {
      return;
    }

    // Build Prolog query to make the move, which will look as follows:
    // put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);
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

    this.setState({
      waiting: true,
    });

    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response["GrillaRes"],
          waiting: false,
        });

        const rowSatisfied = response["FilaSat"];
        const colSatisfied = response["ColSat"];
        const rowClueToPaint =
          document.getElementsByClassName("rowClues")[0].childNodes[i];
        const colClueToPaint =
          document.getElementsByClassName("colClues")[0].childNodes[j + 1];

        //pinta la pista que se está cumpliendo
        if (rowSatisfied) {
          rowClueToPaint.style = "background: gray";
        } else {
          rowClueToPaint.style = "background: null";
        }
        if (colSatisfied) {
          colClueToPaint.style = "background: gray";
        } else {
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
    return (
      <div className="game">
        <Board
          grid={this.state.grid}
          rowClues={this.state.rowClues}
          colClues={this.state.colClues}
          onClick={(i, j) => this.handleClick(i, j)}
        />
        <Mode onClick={(e) => this.handleModeClick(e)} />
        <Level onClick={() => this.loadLevel(1)} />
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
