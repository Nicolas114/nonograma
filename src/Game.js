import React from "react";
import PengineClient from "./PengineClient";
import Board from "./Board";
import Mode from "./Mode";
import RevealSolution from "./RevealSolution"
import RevealCell from "./RevealCell";

/**
 * Componente Game - componente principal de la aplicación. Se encarga de realizar las consultas al servidor Prolog, de renderizar el nonograma en su conjunto
 * y de permitirle al usuario una interacción con el juego.
 */
class Game extends React.Component {
  pengine;

  constructor(props) {
    super(props);
    this.state = {
      grid: null, //la grilla con la que interactua el jugador
      solvedGrid: null, //la grilla resuelta
      showingGridSolution: false, //estado en el cual se indica si se está mostrando la solucion del tablero o no
      showingCellSolution: false, //estado en el cual se indica si se busca revelar la solucion de una celda cada vez que se presiona en ella.
      gridAux: null, //grilla auxiliar para facilitar el cambio entre la grilla resuelta y la grilla con la que el jugador está interactuando
      mode: "#", //el modo de pintado -- "#" significa rellenar, "X" es pintar con una cruz.
      rowClues: null, //estructura de pistas de las filas de la grilla
      satisfiedRowClues: [], //estructura de las pistas de las filas de la grilla que están satisfechas
      colClues: null, //estructura de pistas de las columnas de la grilla
      satisfiedColClues: [], //estructura de las pistas de las columnas de la grilla que están satisfechas
      win: 0, //el estado actual del juego en cuanto a si la partida está finalizada o no
      waiting: false, //true si se está esperando por una respuesta del servidor, false en caso contrario
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  /**
   * Inicializa la grilla del juego mediante la consulta init/3 al servidor Prolog.
   * Establece el estado del componente de acuerdo a los resultados obtenidos, y realiza un chequeo inicial para verificar si algunas pistas
   * de la grilla ya están satisfechas.
   */
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
        this.generateEmptyGrid();
      }
    });
  }

  /**
   * Genera una grilla vacía de iguales dimensiones a la grilla con la que interactúa el usuario, a fin de poder enviársela a Prolog mediante la consulta "solve/4" y obtener la solución a dicha grilla.
   */
  generateEmptyGrid() {

    var emptyGrid = [];
    const rowLength = this.state.grid.length;
    const colLength = this.state.grid[0].length;
    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);

    //llena con "_" todos los elementos de la matriz/grilla
    emptyGrid = Array(rowLength).fill().map(()=>Array(colLength).fill("_"));
 
    this.setState({
      emptyGrid: emptyGrid,
    });

    emptyGrid = JSON.stringify(emptyGrid).replaceAll('"_"', "_");
  
    const queryS = "solve(" + emptyGrid + ", " + rowClues + ", " + colClues + ", GrillaResuelta)";
    const statusText = document.getElementById("statusText");
    var auxContent = statusText.textContent;

    this.setState({
      waiting: true,
    });

    statusText.textContent = "Generating Solution..."
    console.log(statusText.textContent);
    
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          solvedGrid: response["GrillaResuelta"],
          waiting: false,
        });
        
        statusText.textContent = auxContent;
        console.log("Solution Generated");
      }
    });

  }

  /**
   * Realiza un chequeo inicial enviando la consulta correspondiente al servidor Prolog. Los resultados se almacenan en el state en forma de listas con
   * valores binarios, indicando qué pistas se están satisfaciendo o no.
   */
  checkeo_inicial() {

    if (this.state.waiting) {
      return; 
    }

    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);
    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_");

    const queryS =
      "checkeo_inicial(" + rowClues + ", " + colClues + ", " + squaresS + ", ResultadosFilas, ResultadosColumnas)";

      this.setState({
        waiting: true,
      });

      this.pengine.query(queryS, (success, response) => {
        if (success) {
          this.setState({
            satisfiedRowClues: response["ResultadosFilas"],
            satisfiedColClues: response["ResultadosColumnas"],
            waiting: false,
          });
        }
      });
  }

  /**
   * Controla las acciones que se deben llevar a cabo cuando se hace click en el botón "Reveal Solution"
   */
  handleRevealingSolution() {
    const solvedGrid = this.state.solvedGrid;
    const revealCellButton = document.getElementById("reveal_cell_button");
    const modeButtons = document.getElementById("mode__button");
    
    if (!this.state.win){ 
      if (!this.state.showingGridSolution) {
        this.setState({
          gridAux: this.state.grid,
          grid: solvedGrid,
          showingGridSolution: true,
        });
        revealCellButton.disabled = true;
        modeButtons.disabled = true;
      }
      else {
        this.setState({
          grid: this.state.gridAux,
          showingGridSolution: false,
        });

        revealCellButton.disabled = false;
        modeButtons.disabled = false;

      }
    }

  }

  /**
   * Función estándar utilizada para cuando se realiza un click en una celda de la grilla.
   * @param {*} i Índice de fila de la grilla
   * @param {*} j Índice de columna de la grilla
   */
  handleClick(i, j) {
    // No action on click if we are waiting.
    if (this.state.waiting) {
      return;
    }

    // Build Prolog query to make the move, which will look as follows:
    // put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);
    var squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.

    if (!this.state.win) {
      if (!this.state.showingGridSolution) {
        if (!this.state.showingCellSolution) {
          const queryS = 'put("' + this.state.mode + '", [' + i + "," + j + "], " + rowClues + ", " + colClues + ", " + squaresS + ", GrillaRes, FilaSat, ColSat)";

          this.setState({
            waiting: true,
          });

          //realiza la consulta de put/7 al servidor Prolog 
          this.pengine.query(queryS, (success, response) => {
            if (success) {
              this.setState({
                grid: response["GrillaRes"],
                waiting: false,
              });

              
              const rowSatisfied = response["FilaSat"]; //almacena el valor de verdad referente a si la fila donde se hizo click satisface su correspondiente pista
              const colSatisfied = response["ColSat"]; //almacena el valor de verdad referente a si la columna donde se hizo click satisface su correspondiente pista

              //copia ambos arreglos para poder realizar el cambio en el state sin mutarlo
              let currentRowChanges = this.state.satisfiedRowClues.slice();
              currentRowChanges[i] = rowSatisfied;
              let currentColChanges = this.state.satisfiedColClues.slice();
              currentColChanges[j] = colSatisfied;

              this.setState({
                satisfiedRowClues: currentRowChanges,
                satisfiedColClues: currentColChanges,
              });

              //finalmente verifica si todas las pistas del juego fueron satisfechas después del click
              this.checkWin();
            } else {
              this.setState({
                waiting: false,
              });
            }
          });
        }
        else {
          const solvedGrid = this.state.solvedGrid;
          const originalGridUpdated = this.state.grid.slice();

          originalGridUpdated[i][j] = solvedGrid[i][j];

          this.setState({
            grid: originalGridUpdated,
          });

          squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_");

          const queryS = "checkeo_inicial(" + rowClues + ", " + colClues + ", " + squaresS + ", ResultadosFilas, ResultadosColumnas)";

          this.pengine.query(queryS, (success, response) => {
            if (success){
              this.setState({
                satisfiedRowClues: response["ResultadosFilas"],
                satisfiedColClues: response["ResultadosColumnas"]
              })
              this.checkWin();
            }
          });

        }
      }
      
    }

  }

  /**
   * Verifica si todas las pistas del juego están satisfechas, ya que de ser así, la partida estaría terminada.
   * Almacena el valor de verdad de esta verificación en el state.
   */
  checkWin() {
    const resultadosFilas = JSON.stringify(this.state.satisfiedRowClues);
    const resultadosColumnas = JSON.stringify(this.state.satisfiedColClues);
    const queryS ="check_win(" + resultadosFilas + ", " + resultadosColumnas + ", Win)";

    this.setState({
      waiting: true,
    })

    if (!this.state.win) {
      this.pengine.query(queryS, (success, response) => {
        if (success) {
          this.setState({
            win: response["Win"],
            waiting: false,
          });
        }
      });
    }
    else {
      
    }
  }

  /**
   * Controla las acciones que se deben llevar a cabo luego de realizar un click sobre el botón "Reveal Cell"
   * @param {*} e Evento provocado por el click
   */
  handleRevealingCell(e){
    const clickedButton = e.currentTarget;

    if (!this.state.win){
      if (!this.state.showingCellSolution){
        this.setState({
          showingCellSolution: true
        });

        clickedButton.style = "background: blue"
      }
      else {
        this.setState({
          showingCellSolution: false
        });

        clickedButton.style = "background: null"
      }
    }
  }

  /**
   * Renderiza los componentes de la aplicación para que el usuario pueda interactuar con ella
   * @returns el bloque de elementos HTML que conforman la aplicacion
   */
  render() {
    if (this.state.win) {
      const statusText = document.getElementById("statusText");
      const showCellButton = document.getElementById("reveal_cell_button");
      const showGridSolutionButton = document.getElementById("reveal_solution_button");
      const modeButton = document.getElementById("mode__button");

      showCellButton.style = "background: null"
      showCellButton.disabled = true;
      showGridSolutionButton.disabled = true;
      modeButton.disabled = true;
      statusText.textContent = "The game is finished"
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
        <div className="revealing_buttons">
          <RevealSolution onClick={() => this.handleRevealingSolution()} ></RevealSolution>
          <RevealCell onClick={(e) => this.handleRevealingCell(e)}></RevealCell>
        </div>
        <div className="statusText" id="statusText">Keep playing</div>
      </div>
    );
  }

  /**
   * Controla las acciones que se deben llevar a cabo luego de realizar un click sobre el componente Mode
   * @param {*} e Evento provocado por el click
   */
  handleModeClick(e) {
    const divmode = e.target.parentElement;
    const clickedButton = e.currentTarget;

    //actualiza el modo de pintado
    this.setState({
      mode: e.target.value,
    });
    if (!this.state.win) {
      if (clickedButton.value === "#") {
        //actualiza los estilos cuando el modo está en "pintar"
        divmode.children[2].style = "border: 2px solid red; background: #020122"
        divmode.children[1].style = "border: null; background: tan"
      } else { //actualiza los estilos cuando el modo está en "X"
        divmode.children[2].style = "border: null; background: #020122"
        divmode.children[1].style = "border: 2px solid red; background: tan"
      }
    }
  }
}

export default Game;
