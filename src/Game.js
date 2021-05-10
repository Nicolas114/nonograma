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
    const queryS = "init(PistasFilas, PistasColumns, Grilla)";
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response["Grilla"],
          rowClues: response["PistasFilas"],
          colClues: response["PistasColumns"],
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
    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const queryS =
      'put("' + this.state.mode + '", [' +
      i +
      "," +
      j +
      "]" +
      ", [], []," +
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
    const statusText = "Keep playing!";
    return (
      <div className="game">
        <Board
          grid={this.state.grid}
          rowClues={this.state.rowClues}
          colClues={this.state.colClues}
          onClick={(i, j) => this.handleClick(i, j)}
        />
        <div className="gameInfo">{statusText}</div>
        <Mode
          onClick={(e) => this.handleModeClick(e)}
          />
      </div>
    );
  }

  handleModeClick(e) {
    const divmode = e.target.parentElement;
    const clickedButton = e.currentTarget;

    this.setState({
      mode: e.target.value,
    })

    if (clickedButton.value == '#'){
      divmode.children[2].style = "background: blue";
      divmode.children[1].style = "background: null";
    }
    else {
      divmode.children[2].style = "background: null";
      divmode.children[1].style = "background: blue";
    }
  }
}

export default Game;
