:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY es el resultado de reemplazar la ocurrencia de X en la posición XIndex de Xs por Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
%

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, FilaSat, ColSat):-
	% NewGrilla es el resultado de reemplazar la fila Row en la posición RowN de Grilla
	% (RowN-ésima fila de Grilla), por una fila nueva NewRow.
	% writeln(Row), writeln(RowN), writeln(NewRow), writeln(Grilla), writeln(NewGrilla),
	replace(Row, RowN, NewRow, Grilla, NewGrilla),
	/* writeln("---"),
	writeln(Row), writeln(RowN), writeln(NewRow), writeln(Grilla), writeln(NewGrilla), */
	
	% NewRow es el resultado de reemplazar la celda Cell en la posición ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posición ColN de Row por Conenido.	 
	(
		replace(Cell, ColN, _, Row, NewRow), 
		%writeln(Cell), writeln(Contenido), writeln(ColN), writeln(Row), writeln("NewRow: "), writeln(NewRow),
		Cell == Contenido
	;
		replace(_Cell, ColN, Contenido, Row, NewRow)
		%writeln(_Cell), writeln(Contenido), writeln(ColN), writeln(Row), writeln("NewRow: "), writeln(NewRow)
	),
	satisfiedRowClue(RowN, PistasFilas, NewGrilla, FilaSat),
	satisfiedColClue(ColN, PistasColumnas, NewGrilla, ColSat).

satisfiedRowClue(RowN, PistasFilas, Grilla, Satisfied):- 
	getEnesimoTarget(RowN, Grilla, Row),
	getEnesimoTarget(RowN, PistasFilas, Clues),
	transformListIntoClueFormat(Row, FormattedRow),
	comparison(FormattedRow, Clues, Satisfied).

satisfiedColClue(ColN, PistasColumnas, Grilla, Satisfied):-
	getColumna(ColN, Grilla, Col),
	getEnesimoTarget(ColN, PistasColumnas, Clues),
	transformListIntoClueFormat(Col, FormattedCol),
	comparison(FormattedCol, Clues, Satisfied).

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

/* FormattedList contiene la lista (primer parametro) en formato Pistas. Ej: [#, X, #, #] --> [1, 2] */
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