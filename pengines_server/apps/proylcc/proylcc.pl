:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANTE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
	En lo que sigue, en varias oportunidades se hará referencia al concepto de "Formato Pistas". Esto surge debido a la forma en la que
	se decidió solucionar el problema de la verificación de filas y columnas de la grilla. Este concepto, básicamente, consiste en 
	transformar una lista de elementos de la grilla (por ejemplo: [#, #, X, _, #]) en otra lista con cierta similitud a las listas que
	se utilizan para representar a las pistas de las filas o de las columnas (por ejemplo: [3, 1, 2]). Para realizar esta transformacion,
	se tiene en cuenta los bloques de "#" presentes en la lista a transformar. A modo de ejemplo:

	Si queremos transformar la lista [#, #, X, _, #] en su correspondiente formato Pistas, tenemos que analizar los diferentes bloques de 
	"#" que están presentes en ella. Vemos que los dos primeros elementos se corresponden a un "#", con lo cual eso compone nuestro primer 
	bloque.	Luego, hay dos elementos que no se corresponden a un "#", así que, independientemente de cuales son dichos elementos, se ignorarán para
	proceder a buscar el siguiente "#" si lo hubiese. Como vemos, el último elemento de la lista es un "#"; con esto, conformamos nuestro
	segundo y último bloque, formado por un solo numeral. Como conclusión, el primer bloque extraído de la lista tiene dos numerales, 
	el segundo tiene uno solo, y ambos bloques están separados por elementos que no son numerales. Esto nos lleva a formar la lista [2, 1].
	En caso de que la lista de elementos original estuviese correspondida a una pista de la forma [2, 1], gracias a este formateo, podemos
	fácilmente comparar ambas listas y concluir que efectivamente la lista original de elementos está satisfaciendo dicha pista.
*/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANTE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*
 replace(?X, +XIndex, +Y, +Xs, -XsY)
 XsY es el resultado de reemplazar la ocurrencia de X en la posición XIndex de Xs por Y.
*/
replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

/*
put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
*/
put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, FilaSat, ColSat):-
	% NewGrilla es el resultado de reemplazar la fila Row en la posición RowN de Grilla
	% (RowN-ésima fila de Grilla), por una fila nueva NewRow.
	replace(Row, RowN, NewRow, Grilla, NewGrilla),
	
	% NewRow es el resultado de reemplazar la celda Cell en la posición ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posición ColN de Row por Conenido.	 
	(
		replace(Cell, ColN, _, Row, NewRow), 
		Cell == Contenido
	;
		replace(_Cell, ColN, Contenido, Row, NewRow)
	),
	%FilaSat es el resultado de verificar si la grilla NewGrilla en la fila RowN cumple con las pistas PistasFilas
	satisfiedRowClue(RowN, PistasFilas, NewGrilla, FilaSat),
	%ColSat es el resultado de verificar si la grilla NewGrilla en la columna ColN cumple con las pistas PistasColumnas
	satisfiedColClue(ColN, PistasColumnas, NewGrilla, ColSat).

/*
satisfiedRowClue(+RowN, +PistasFilas, +Grilla, -Satisfied).
Verifica si la Grilla en la fila RowN verifica las PistasFilas.
@param RowN - (integer) Numero que representa la fila en la que se va a realizar la verificación
@param PistasFilas - (List) Lista de listas que contiene a las pistas de las filas
@param Grilla - (List) Lista de listas que contiene a los elementos que forman parte del tablero
@param Satisfied - (integer) Resultado de la verificación: 1 si la grilla verifica las pistas, 0 en caso contrario
*/
satisfiedRowClue(RowN, PistasFilas, Grilla, Satisfied):- 
	%Row es la lista de elementos que se "extrae" de la Grilla en la posición RowN
	getEnesimoTarget(RowN, Grilla, Row),
	%Clues es la lista de pistas que se extrae de las PistasFilas en la posición RowN (que corresponde a la fila Row calculada anteriormente)
	getEnesimoTarget(RowN, PistasFilas, Clues),
	%FormattedRow es el resultado de "formatear" o transformar la lista de elementos Row en una "lista con formato pistas". Ejemplo: si Row = [#, #, _, X, #] se mapea en FormattedRow = [2, 1] pues tiene un bloque de dos # al inicio, separado de otro bloque de 1 #
	transformListIntoClueFormat(Row, FormattedRow),
	%Satisfied es el resultado de comparar la lista formateada FormattedRow con la lista de pistas Clues: 1 si son iguales, 0 en caso contrario.
	comparison(FormattedRow, Clues, Satisfied).

/*
satisfiedColClue(+ColN, +PistasColumnas, +Grilla, -Satisfied).
Verifica si la Grilla en la columna ColN verifica las PistasColumnas.
@param ColN - (integer) Numero que representa la columna en la que se va a realizar la verificación
@param PistasColumnas - (List) Lista de listas que contiene a las pistas de las columnas
@param Grilla - (List) Lista de listas que contiene a los elementos que forman parte del tablero
@param Satisfied - (integer) Resultado de la verificación: 1 si la grilla verifica las pistas, 0 en caso contrario
*/
satisfiedColClue(ColN, PistasColumnas, Grilla, Satisfied):-
	%Col es la lista de elementos que se extrae de la Grilla en la posición ColN
	getColumna(ColN, Grilla, Col),
	%Clues es la lista de pistas que se extrae de las PistasColumnas en la posición ColN (que corresponde a la columna Col calculada anteriormente)
	getEnesimoTarget(ColN, PistasColumnas, Clues),
	%FormattedCol es el resultado de "formatear" o transformar la lista de elementos Col en una "lista con formato pistas". Ejemplo: si Col = [#, #, _, X, #] se mapea en FormattedCol = [2, 1] pues tiene un bloque de dos # al inicio, separado de otro bloque de 1 #
	transformListIntoClueFormat(Col, FormattedCol),
	%Satisfied es el resultado de comparar la lista formateada FormattedCol con la lista de pistas Clues: 1 si son iguales, 0 en caso contrario.
	comparison(FormattedCol, Clues, Satisfied).


/*
checkeo_inicial(+PistasFilas, +PistasColumnas, +Grilla, -ResultadosFilas, -ResultadosColumnas)
Realiza una verificación inicial de todas las filas y columnas de la grilla con el fin de guardar en dos listas aparte los resultados
de las comparaciones
@param PistasFilas - (List) Lista de listas que contiene a las pistas de las filas
@param PistasColumnas - (List) Lista de listas que contiene a las pistas de las columnas
@param Grilla - (List) Lista de listas que contiene a los elementos que forman parte del tablero
@param ResultadosFilas - (List) Lista de unos y ceros correspondientes a las filas que están satisfechas o no, respectivamente
@param ResultadosColumnas - (List) Lista de unos y ceros correspondientes a las columnas que están satisfechas o no, respectivamente
*/ 
checkeo_inicial(PistasFilas, PistasColumnas, Grilla, ResultadosFilas, ResultadosColumnas):-
	%primero se verifican las filas
	checkeo_filas(PistasFilas, Grilla, ResultadosFilas),
	%Max es el resultado de evaluar la longitud de la lista de PistasColumnas, mediante el predicado predefinido length/20
	length(PistasColumnas, Max),
	%por último se verifican las columnas utilizando un contador que variará de 0 a Max
	checkeo_columnas(PistasColumnas, Grilla, 0, Max, ResultadosColumnas),
	!.


/* 
checkeo_filas(+PistasFilas, +Grilla, -ResultadosFilas)
Guarda en una lista ResultadosFilas los resultados de evaluar cada fila de la grilla con su correspondiente pista (1 si la satisface, 0 en caso contrario)
*/

/* Caso Base: Si ambas listas están vacías, se devuelve una lista vacía pues no hay nada que verificar */
checkeo_filas([], [], []).

/* 
Caso Recursivo: Si ambas listas tienen elementos, se procede a hacer la verificación con sus primeros elementos, y 
luego se realiza la verificación en PistasFilas' y Grilla', donde PistasFilas' y Grilla' son PistasFilas y Grilla sin su primer elemento, respectivamente
   */
checkeo_filas([PF|PFr], [FG|FGr], [Satisfied|Resultados]):- 
	%se transforma el primer elemento de la grilla en el formato Pistas y se guarda en FormattedFG
	transformListIntoClueFormat(FG, FormattedFG),
	%se realiza la comparación entre la lista formateada y la pista correspondiente, y se guarda en Satisfied.
	comparison(FormattedFG, PF, Satisfied),
	%se realiza el llamado recursivo a los restantes elementos de ambas listas
	checkeo_filas(PFr, FGr, Resultados).

checkeo_columnas([], [], _, _, []).
checkeo_columnas([], [_Ge|_Ger], _, _, []).

checkeo_columnas([PC|PCr], Grilla, Index, Max, [Satisfied|Resultados]):- 
    Index < Max,
	getColumna(Index, Grilla, Columna),
	transformListIntoClueFormat(Columna, FormattedCG),
	comparison(FormattedCG, PC, Satisfied),
	IndexS is Index + 1,
	checkeo_columnas(PCr, Grilla, IndexS, Max, Resultados).

check_win(ResultadosFilas, ResultadosColumnas, Win):- 
	todosUnos(ResultadosFilas, TodosUnos1), 
	todosUnos(ResultadosColumnas, TodosUnos2), 
	iguales(TodosUnos1, TodosUnos2, Win).

/* PREDICADOS AUXILIARES */

todosUnos([1], 1).
todosUnos([0|_], 0).

todosUnos([1|Rest], TodosUnos):- todosUnos(Rest, TodosUnos).

iguales(1, 1, 1).
iguales(1, 0, 0).
iguales(0, 1, 0).
iguales(0, 0, 0).

getColumna(_, [], []).

getColumna(N, [X|Xs], [Element|Rest]):-
	find_element(0, N, X, Element),
	getColumna(N, Xs, Rest).

find_element(J, N, [X|_], X):- N is J.
find_element(J, N, [_|Xs], Result):-
	not(N is J), J2 is J + 1, find_element(J2, N, Xs, Result).

%obtiene la N-ésima fila/columna (primer parametro) de la lista objetivo (segundo parámetro) para almacenarla en Target (tercer parametro)
getEnesimoTarget(0, [Target|_], Target).
getEnesimoTarget(N, [_|Gs], Target):- N > 0, Ns is N - 1, getEnesimoTarget(Ns, Gs, Target).

/* FormattedList contiene la lista (primer parametro) en formato Pistas. Ej: [#, X, _, #, #] --> [1, 2] */
transformListIntoClueFormat(List, FormattedList):- transformAux(0, List, FormattedList).

transformAux(0, [], []).
transformAux(Count, [], [Count]).

transformAux(Count, [X|Xs], [Count|Result]):- X \== "#", not(Count is 0), transformAux(0, Xs, Result).
transformAux(Count, [X|Xs], Result):- X \== "#", Count is 0, transformAux(0, Xs, Result).
transformAux(Count, [X|Xs], Result):- X == "#", CountS is Count + 1, transformAux(CountS, Xs, Result).

comparison([], [], 1).
comparison([], Ys, 0).
comparison(Xs, [], 0).
comparison([X|Xs], [Y|Ys], 0):- dif(X, Y).

comparison([X|Xs], [Y|Ys], Result):- X == Y, comparison(Xs, Ys, Result).