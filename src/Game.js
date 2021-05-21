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
      satisfiedRowClues: [],
      colClues: null,
      satisfiedColClues: [],
      win: 0,
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
        this.checkeo_inicial();
      }
    });
  }

  checkeo_inicial() {
    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);
    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_");

    const queryS =
      "checkeo_inicial(" +
      rowClues +
      ", " +
      colClues +
      ", " +
      squaresS +
      ", ResultadosFilas, ResultadosColumnas)";
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          satisfiedRowClues: response["ResultadosFilas"],
          satisfiedColClues: response["ResultadosColumnas"],
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

    if (!this.state.win) {
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

          let currentRowChanges = this.state.satisfiedRowClues.slice();
          currentRowChanges[i] = rowSatisfied;
          let currentColChanges = this.state.satisfiedColClues.slice();
          currentColChanges[j] = colSatisfied;

          this.setState({
            satisfiedRowClues: currentRowChanges,
            satisfiedColClues: currentColChanges,
          });

          this.checkWin();
        } else {
          this.setState({
            waiting: false,
          });
        }
      });
    }

  }

  checkWin() {
    const resultadosFilas = JSON.stringify(this.state.satisfiedRowClues);
    const resultadosColumnas = JSON.stringify(this.state.satisfiedColClues);
    const queryS =
      "check_win(" + resultadosFilas + ", " + resultadosColumnas + ", Win)";

    if (!this.state.win) {
      this.pengine.query(queryS, (success, response) => {
        if (success) {
          this.setState({
            win: response["Win"],
          });
        }
      });
    }
    else {
      
    }
  }

  render() {
    if (this.state.win) {
      const statusText = document.getElementById("statusText");
      statusText.textContent = "WIN"
    }
    if (this.state.grid === null) {
      return null;
    }
    return (
      <div className="game">
        <Board
          grid={this.state.grid}
          rowClues={this.state.rowClues}
          colClues={this.state.colClues}
          rowStates={this.state.satisfiedRowClues}
          colStates={this.state.satisfiedColClues}
          onClick={(i, j) => this.handleClick(i, j)}
        />
        <Mode onClick={(e) => this.handleModeClick(e)} />
        <div className="statusText" id="statusText">Keep playing</div>
      </div>
    );
  }

  handleModeClick(e) {
    const divmode = e.target.parentElement;
    const clickedButton = e.currentTarget;

    this.setState({
      mode: e.target.value,
    });
    if (!this.state.win) {
      if (clickedButton.value === "#") {
        divmode.children[2].style = "border: 2px solid red; background: #020122"
        divmode.children[1].style = "border: null; background: tan"
      } else {
        divmode.children[2].style = "border: null; background: #020122"
        divmode.children[1].style = "border: 2px solid red; background: tan"
      }
    }
  }
}

export default Game;
