:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANTE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
	En lo que sigue, en varias oportunidades se hará referencia al concepto de "Formato Pistas". Esto surge debido a la forma en la que
	se decidió solucionar el problema de la verificación de filas y columnas de la grilla. Este concepto, básicamente, consiste en 
	transformar una lista de elementos de la grilla (por ejemplo: [#, #, X, _, #]) en otra lista cuyo formato tiene cierta similitud a las listas que
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREDICADOS PRINCIPALES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
transformListIntoClueFormat(+List, -FormattedList)
Realiza la conversión tal que FormattedList contiene a la lista List en formato Pistas (ver aclaración del inicio). Ej: [#, X, _, #, #] --> [1, 2]
*/
transformListIntoClueFormat(List, FormattedList):- transformAux(0, List, FormattedList). %llamamos a un predicado auxiliar con un contador en cero como primer parametro

/* 
check_win(+ResultadosFilas, +ResultadosColumnas, -Win)
Devuelve 1 o 0 dependiendo de si sus dos listas de entrada están formadas por unos solamente.
@param ResultadosFilas - (List) Lista de unos y ceros que indica cuáles filas de la grilla satisfacen las pistas correspondiente a su posición
@param ResultadosColumnas - (List) Ídem, pero con las columnas
@param Win - (integer) Indica si todas las pistas fueron satisfechas o no. En otros términos, indica si el jugador ganó la partida.
 */
check_win(ResultadosFilas, ResultadosColumnas, Win):- 
	todosUnos(ResultadosFilas, TodosUnos1), 
	todosUnos(ResultadosColumnas, TodosUnos2), 
	iguales(TodosUnos1, TodosUnos2, Win).


/* 
(*) Recordemos que la grilla tiene el siguiente formato:
[["#", "#" , "#" , _ , _ ], --> fila 1
 ["#", "#" ,"#", _ , _ ], --> fila 2 ...
 ["#", "#" , _ , _ , _ ],
 ["#","#","#", _ , _ ],
 ["X" , _ ,"#","#","#"]]
   |	|
 col1 col2 ...

Como se ve, es fácil obtener una fila de la grilla y operar con ella; no así para las columnas.
Esto provoca que para operar con columnas, se deba tener en cuenta situaciones que al trabajar con filas, no eran posibles.
La forma en la que se obtiene una columna de la grilla quedará explicada en el predicado getColumna/3
*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREDICADOS AUXILIARES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
checkeo_filas(+PistasFilas, +Grilla, -ResultadosFilas)
Guarda en una lista ResultadosFilas los resultados de evaluar cada fila de la grilla con su correspondiente pista (1 si la satisface, 0 en caso contrario)
*/

/* Caso Base: Si no hay pistas ni grilla por recorrer, se devuelve una lista vacía pues no hay nada que verificar */
checkeo_filas([], [], []).

/* 
Caso Recursivo: Si hay pistas y grilla por recorrer, y tienen elementos, se procede a hacer la verificación con sus primeros elementos, y 
luego se realiza la verificación en PistasFilas' y Grilla', donde PistasFilas' y Grilla' son PistasFilas y Grilla sin su primer elemento, respectivamente
   */
checkeo_filas([PF|PFr], [FG|FGr], [Satisfied|Resultados]):- 
	%se transforma el primer elemento de la grilla en el formato Pistas y se guarda en FormattedFG
	transformListIntoClueFormat(FG, FormattedFG),
	%se realiza la comparación entre la lista formateada y la pista correspondiente, y se guarda en Satisfied.
	comparison(FormattedFG, PF, Satisfied),
	%se realiza el llamado recursivo a los restantes elementos de ambas listas, junto con la lista de unos y ceros que vamos teniendo hasta el momento
	checkeo_filas(PFr, FGr, Resultados).


/* 
checkeo_columnas(+PistasColumnas, +Grilla, +Counter, +Max, -ResultadosColumnas)
Guarda en una lista ResultadosColumnas los resultados de evaluar cada columna de la grilla con su correspondiente pista (1 si la satisface, 0 en caso contrario)
@param Counter - (integer) Count que servirá para recorrer las columnas de la grilla
@param Max - (integer) Número cuyo proposito es establecer el valor máximo que puede tomar Counter (i. e. el máximo de columnas que se pueden recorrer)
*/

/*
Caso Base 1: si no hay pistas ni grilla por recorrer, independientemente del valor del contador o del máximo, se devuelve una lista vacía.
Caso Base 2: si no hay pistas por recorrer, pero sí hay elementos de la grilla, se devuelve una lista vacía (situación en que hay más filas que columnas) (*)
*/
checkeo_columnas([], [], _, _, []).
checkeo_columnas([], [_Ge|_Ger], _, _, []).

/* 
Caso Recursivo: si hay pistas por recorrer, se realiza la verificación obteniendo la columna correspondiente a Index, formateandola
y comparandola con su correspondiente pista, y luego se procede a repetir el proceso con la lista de pistas sin su primer elemento y el
ìndice aumentado en 1.
*/
checkeo_columnas([PC|PCr], Grilla, Index, Max, [Satisfied|Resultados]):- 
	%aseguramos que el índice no supere el valor máximo
    Index < Max,
	%obtenemos la Columna de la grilla correspondiente a la posición Index
	getColumna(Index, Grilla, Columna),
	%transformamos la Columna obtenida en su correspondiente lista en formato Pistas.
	transformListIntoClueFormat(Columna, FormattedCG),
	%comparamos la lista formateada con la pista correspondiente, y guardamos el resultado en Satisfied
	comparison(FormattedCG, PC, Satisfied),
	IndexS is Index + 1,
	%llamamos recursivamente al predicado con el resto de la lista de pistas, la grilla, el índice aumentado en 1, el limite y la lista de unos y ceros que vamos teniendo hasta el momento
	checkeo_columnas(PCr, Grilla, IndexS, Max, Resultados).


/* 
todosUnos(+Lista, -TodosUnos)
Guarda en TodosUnos el resultado de haber comprobado que efectivamente la lista está formada únicamente por unos. 
*/
/* 
Caso Base 1: Si la lista tiene un solo elemento y es un uno, se devuelve un uno
Caso Base 2: Si la lista contiene un cero en algún lugar, independientemente de lo que haya en el resto de la lista, se devuelve 0
 */
todosUnos([1], 1).
todosUnos([0|_], 0).

%Caso Recursivo: si el primer elemento de la lista es un 1, se analiza Lista', donde Lista' es la Lista original sin su primer elemento
todosUnos([1|Rest], TodosUnos):- todosUnos(Rest, TodosUnos).

/*
iguales(+Num1, +Num2, -Comparacion)
Devuelve en Comparacion el resultado de evaluar el valor de Num1 con Num2.
Como este predicado sólo se va a llamar con valores booleanos (0 o 1), se prescinde de cualquier otro mecanismo de comparación
y sólo se realiza la operación AND entre num1 y num2
*/
iguales(1, 1, 1).
iguales(1, 0, 0).
iguales(0, 1, 0).
iguales(0, 0, 0).

/* 
getColumna(+Index, +Grilla, -Columna)
Obtiene la columna en la posición Index de Grilla y la guarda en Columna
*/
 
%Caso Base: si la grilla está vacía, entonces se devuelve una columna vacía, sin importar el índice
getColumna(_, [], []).

/* 
Caso recursivo: si la grilla tiene elementos (listas de elementos) se procede a buscar el elemento especifico en el índice N parametrizado,
para añadirlo a la lista a devolver. Luego, se prosigue con la búsqueda de los demás elementos en las siguientes listas de la grilla
*/
getColumna(Index, [X|Xs], [Element|Rest]):-
	%buscamos el elemento específico dentro de la lista de la grilla en la posición Index y lo guardamos en Element. El 0 del primer parametro es el valor que se le va a asignar al contador (ver find_element/4)
	find_element(0, Index, X, Element),
	%llamamos recursivamente con el mismo índice y con el resto de las listas de la grilla, para seguir buscando los elementos y seguir armando la columna resultante
	getColumna(Index, Xs, Rest).

/* 
find_element(+Counter, +Max, +List, -Element)
Busca el elemento en la posición Max dentro de la lista, utilizando un contador Counter que va desde 0 hasta Max
 */

 %Caso Base: si el contador llega al valor máximo Max, entonces se ha encontrado el elemento buscado, por lo que se guarda en el elemento a devolver
find_element(Max, Max, [X|_], X).

%Caso recursivo: si el contador todavía no llegó al elemento máximo es porque aún no se ha llegado al elemento buscado en la lista L; entonces,
%se incrementa el contador y se busca en L', donde L' es L sin su primer elemento.
find_element(Counter, Max, [_|Xs], Result):-
	Counter < Max,
	CounterS is Counter + 1,
	find_element(CounterS, Max, Xs, Result).


/* 
getEnesimoTarget(+N, +ListaObjetivo, -Target)
Obtiene la N-ésima posición (primer parametro) de la ListaObjetivo (segundo parámetro) para almacenarla en Target (tercer parametro)
 */

%Caso base: si N es 0, se busca el primer elemento de la lista, por lo que se almacena en la variable a devolver
getEnesimoTarget(0, [Target|_], Target).

%Caso Recursivo: si N no es cero, significa que aún no se encontró el elemento buscado en la lista L, con lo cual se reduce su valor en 1 y se llama a buscar
%en la lista L', donde L' es L sin su primer elemento.
getEnesimoTarget(N, [_|Gs], Target):- 
	N > 0,
	NS is N - 1, 
	getEnesimoTarget(NS, Gs, Target).

/* 
transformAux(+Count, +List, -FormattedList)
Se encarga de realizar el formateo de la lista List mediante un contador que representa la cantidad de numerales ("#") que fueron leídos hasta el momento
*/

/* 
Caso Base 1: si no se leyó ningún numeral y no queda nada más por leer de la lista List, se devuelve una lista vacía
Caso Base 2: si se leyeron Count numerales y no queda nada más por leer de la lista list, se devuelve una lista que contenga el número de numerales leídos hasta el momento (i.e Count)
 */
transformAux(0, [], []).
transformAux(Count, [], [Count]).

/* 
Caso recursivo 1: si el primer elemento X que se está leyendo de la lista L ES un numeral, se incrementa el contador en 1 y se procede a seguir
recorriendo en la lista L', donde L' es L sin su primer elemento
Caso recursivo 2: si el primer elemento X que se está leyendo de la lista L NO es un numeral, y el contador de numerales hasta el 
momento NO es cero, se almacena su valor en la lista Result y se procede a seguir recorriendo la lista L' con el contador 
reiniciado a cero, donde L' es L sin su primer elemento
Caso recursivo 3: si el primer elemento X que se está leyendo de la lista L NO es un numeral, y el contador hasta el momento es cero,
simplemente se ignora y se procede a seguir recorriendo en la lista L', donde L' es L sin su primer elemento
*/
transformAux(Count, [X|Xs], Result):- X == "#", CountS is Count + 1, transformAux(CountS, Xs, Result).
transformAux(Count, [X|Xs], [Count|Result]):- X \== "#", \+(Count is 0), transformAux(0, Xs, Result).
transformAux(Count, [X|Xs], Result):- X \== "#", Count is 0, transformAux(0, Xs, Result).

/* 
comparison(+Lista1, +Lista2, -Resultado)
Resultado es el resultado (valga la redundancia) de comparar la Lista1 con la Lista2, tal que es 1 si ambas listas son iguales o cero en caso contrario.
*/

/* 
Caso Base 1: si ambas listas son vacías, entonces son iguales, por lo que Resultado es 1
Caso Base 2: si Lista1 es vacía y Lista2 tiene elementos, entonces no son iguales, por lo que Resultado es 0
Caso Base 3: si Lista1 tiene elementos y Lista2 es vacía, entonces no son iguales
Caso Base 4: si ambas listas tienen elementos, y sus primeros elementos son diferentes, entonces no son iguales
 */
comparison(L, L, 1).

comparison(L1, L2, 0):- L1 \= L2.











%%%%%%%%%%%%%%%%%%%%%%%%%% PARTE 2 %%%%%%%%%%%%%%%%%%%








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANTE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
	En lo que sigue se va a referir al concepto de "cauta", "jugada cauta", "lista cauta", "fila/columna cauta", entre otros. Algunos sinónimos para este término pueden ser "precavido", "previsor", "discreto", etc. Los mismos fueron elegidos apropiadamente según el contexto de esta aplicación. A lo que se refiere este término en el contexto de esta aplicación es al hecho de que, al momento de resolver un nonograma de forma algorítmica (esto es, automatizada o hecha por la 'inteligencia' de la computadora), existen situaciones en las cuales una cierta fila o columna pueden ser completadas de forma certera, sin ambigüedad, o mejor dicho, sin que exista la posibilidad de considerar que en una celda que se completó con un "#", en realidad deba completarse con un "X" y viceversa. Visto con un ejemplo:

	Supongamos que se tiene una grilla de dimensiones 5x5 como sigue:

	[[_, _, _, _, _], --> fila 0
	[_, _, _, _, _],  --> fila 1
	[_, _, _, _, _],  --> fila 2
	[_, _, _, _, _],  --> fila 3
	[_, _, _, _, _]]  --> fila 4

	y tomemos, sin pérdida de generalidad, la fila 0.
	
	CASO (A): Supongamos que la pista correspondiente a la fila 0 es [5]. Esto indica que debe haber 5 celdas consecutivas pintadas. Luego, toda la fila tomada debe ser pintada, pues es de longitud 5. Luego, resulta en [#, #, #, #, #]. Notemos que **no** existe otra posibilidad para esta fila, puesto que tiene 5 celdas libres, y su pista correspondiente indica que deben pintarse 5 celdas consecutivas.
	CASO (B): Supongamos que la pista correspondiente a la fila 0 es [1, 1, 1]. Esto indica que debe haber 3 bloques de una celda pintada separadas por uno o más espacios entre ellas. Nótese que la única posibilidad para completar la fila tomada es que resulte en [#, X, #, X, #].
	CASO (C): Supongamos que la pista correspondiente a la fila 0 es [2, 1]. Esto indica que debe haber 2 bloques de dos y una celdas pintadas separadas por uno o más espacio entre ellas. La rama de posibilidades aumenta de forma que:
		-Una posibilidad es que resulte en  [#, #, X, #, X]
		-Otra posibilidad es que resulte en [#, #, X, X, #]
		-Otra posibilidad es que resulte en [X, #, #, X, #]
	Luego, para el caso (C), no existe una única posibilidad de completar la fila. Sin embargo, se puede detectar que hay celdas que siempre están pintadas a lo largo de las posibilidades. Si observamos las 3 posibilidades, notamos que el segundo elemento siempre está pintado, con lo cual, en una primera instancia, ese elemento se pintaría.

	A la hora de resolver un nonograma, el algoritmo presentado realizará dos "pasadas" obteniendo diferentes aproximaciones de la solución final. La primera pasada resuelve casos como el (A) y el (B), esto es, filas/columnas con una única posibilidad de resolución, mientras que la segunda pasada resuelve casos como el (C), esto es, filas/columnas con varias posibilidades de resolución, pero con celdas que sí o sí deben estar pintadas.

*/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREDICADOS PRINCIPALES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*
solve(+Grilla, +PistasFilas, +PistasCol, -GrillaResuelta)
Dada una grilla VACÍA, y las listas de pistas de las filas y columnas, procesa y guarda en GrillaResuelta la grilla parametrizada con todas sus celdas completadas correctamente.
Se asume que la grilla inicial tiene una única solución.
*/
solve(Grilla, PistasFilas, PistasCol, GrillaResuelta):-
	%obtiene la longitud de las filas de la grilla
	length(PistasCol, LongitudFilas),
	%obtiene la longitud de las columnas de la grilla
	length(PistasFilas, LongitudColumnas),
	%se obtiene una primer aproximación de la grilla completando aquellas filas y columnas que tienen una única posibilidad de solución
	firstApproximation(Grilla, PistasFilas, PistasCol, LongitudFilas, LongitudColumnas, GrillaListasCautas),
	%se obtiene una segunda aproximación de la grilla completando aquellas filas y columnas mediante un algoritmo progresivo de completado cauto, esto es, de pintado de celdas seguras.
	secondApproximation(GrillaListasCautas, PistasFilas, PistasCol, LongitudFilas, LongitudColumnas, GrillaResuelta),
	%hace un cut para evitar generar más soluciones, ya que la primera solución alcanza (y es la correcta)
	!.

/*
firstApproximation(+GrillaIn, +PistasFila, +PistasCol, +LongitudFilas, +LongitudColumnas, -GrillaPrimerPasada)
Dada una grilla vacía GrillaIn, las listas de PistasFila y PistasCol correspondientes, guarda en GrillaPrimerPasada el resultado del proceso de completado de filas y columnas que se pueden completar en una sola pasada de la grilla inicial GrillaIn. Ver la aclaración del inicio para más informacion.
*/
firstApproximation(GrillaIn, PistasFila, PistasCol, LongitudFilas, LongitudColumnas, GrillaPrimerPasada):-
	%realiza la primer pasada por las filas de la grilla, completando aquellas que son seguras de completar en una sola movida y guardandola en GrillaResultado1
	firstApproximationAux(GrillaIn, PistasFila, LongitudFilas, GrillaResultado1),
	%transpone la GrillaResultado1 para poder operar facilmente con las columnas
	transpose(GrillaResultado1, GrillaTranspuesta),
	%realiza la primer pasada por las columnas de la grilla, completando aquellas que son seguras de completar en una sola movida y guardándola en GrillaResultado2
	firstApproximationAux(GrillaTranspuesta, PistasCol, LongitudColumnas, GrillaResultado2),
	%transpone la GrillaResultado2 para obtener la Grilla original con las celdas correspondientes completadas.
	transpose(GrillaResultado2, GrillaPrimerPasada).

/* 
secondApproximation(+GrillaListasCautas, +PistasFilas, +PistasCol, +LongitudFilas, +LongitudColumnas, -GrillaResuelta)
Dada una grilla con aquellas filas/columnas con única solucion completadas, y las listas de pistas referidas a las filas y a las columnas, el predicado opera de la siguiente forma:
	-Corrobora que todas las celdas de la grilla estén pintadas con un "#" o una "X" (es decir, no hay variables)
	-Si la corroboración fue exitosa entonces el nonograma está resuelto y el predicado está satisfecho (primer predicado).
	-Si la corroboración falló, es porque hay al menos una variable en el tablero, por lo que el predicado se encarga de obtener una aproximación más refinada del tablero completando la mayor cantidad de celdas que no están pintadas (segundo predicado).
 */

secondApproximation(Grilla, _PistasFilas, _PistasCol, _LongitudFilas, _LongitudColumnas, Grilla):-
	%corrobora que no haya variables en la grilla
	forall(
		member(L, Grilla), (
			forall(
					member(X, L),
					\+(var(X))
				)
			)
	).

secondApproximation(Grilla, PistasFilas, PistasCol, LongitudFilas, LongitudColumnas, GrillaRes):-
	%completa las filas que son cautas
	completarListasCautas(Grilla, PistasFilas, LongitudFilas, GrillaAux1),
	%transpone la grilla para poder trabajar fácilmente con las columnas y poder utilizar el mismo predicado
	transpose(GrillaAux1, GrillaTranspuesta1),
	%completa las columnas que son cautas
	completarListasCautas(GrillaTranspuesta1, PistasCol, LongitudColumnas, GrillaAux2),
	%transpone la grilla recibida para volver a su estado normal
	transpose(GrillaAux2, GrillaTranspuesta2),
	secondApproximation(GrillaTranspuesta2, PistasFilas, PistasCol, LongitudFilas, LongitudColumnas, GrillaRes).

/* 
esListaCauta(+ListaDePistas, +ListaGrilla)
Verifica si la suma de los valores de una pista dada con la longitud de dicha pista (por ejemplo, [1,3] tiene longitud 2) disminuído en 1 es equivalente a la longitud de la lista de la grilla parametrizada. Esta condición es fundamental ya que verifica que una lista dada puede ser completada en una sola movida
 */
esListaCauta(ListaDePistas, ListaGrilla):- 
	sumarPistas(ListaDePistas, SumaValoresPistas),
	length(ListaDePistas, LongitudPistas),
	length(ListaGrilla, LongitudLista),
	(SumaValoresPistas + LongitudPistas) - 1 =:= LongitudLista.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREDICADOS AUXILIARES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/* 
armarListaSegunPista(+Pista, -Lista)
Dada una Pista parametrizada, arma y guarda en Lista la lista que respete las pistas indicadas. Por ejemplo, si Pista = [1,2], una de las listas que respeta esta pista es L = [#, X, #, #] 
 */
armarListaSegunPista([],[]).

armarListaSegunPista([P|Ps], ["#"|Ls]):-
	generarNElementos(P, ["#"|Ls], Rest),
	armarListaSegunPista(Ps, Rest).

armarListaSegunPista(Ps, ["X"|Ls]):-
	armarListaSegunPista(Ps, Ls).


/*
allAtoms(+Elemento, +Lista)
Dado un Elemento y una Lista, corrobora que todos los elementos de la lista sean iguales al Elemento parametrizado.
*/

/* 
Caso base: La lista está vacía, no hay nada que recorrer
 */
allAtoms(_Elem, []).

/* 
Caso recursivo: la lista L tiene al menos un elemento, con lo que se corrobora si es igual al Elem parametrizado, para luego repetir el proceso con L', donde L' es L sin su primer elemento.
 */
allAtoms(Elem, [X|L]):-
	X == Elem,
	allAtoms(Elem, L).

/* 
sumarPistas(+ListaDePistas, -Suma)
Suma los valores de las pistas de una lista de pistas y lo guarda en Suma
 */
sumarPistas([], 0).
sumarPistas([E|Es], Suma):-
	sumarPistas(Es, SumaAux),
	Suma is SumaAux + E.

%Referencia: https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog (Cómo transponer una matriz en Prolog)
transpose([], []).
transpose([F|Fs], Ts):-
	transpose(F, [F|Fs], Ts).
transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]):-
	lists_firsts_rests(Ms, Ts, Ms1),
	transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]):-
	lists_firsts_rests(Rest, Fs, Oss).
%Fin referencia

/* 
generarNElementos(+N, -ListaResultante, -Rest)
Genera N elementos consecutivos y los guarda en ListaResultante, separados por un "X" de Rest. Ejemplo: la consulta generarNElementos(2, L, ["X", "X", "#", "X", "#"]). devuelve L = ["#", "#", "X", "X", "X", "#", "X", "#"], donde los dos primeros elementos son los generados. 
 */
generarNElementos(0, [], []).

generarNElementos(0, ["X"|ListaResultante], ListaResultante).

generarNElementos(N, ["#"|ListaResultante], Rest):-
	N > 0,
	NS is N - 1,
	generarNElementos(NS, ListaResultante, Rest).


/* 
firstApproximationAux(+GrillaIn, +Pistas, +Longitud, -GrillaResultado),
Dada una grilla de entrada GrillaIn, la lista de Pistas correspondientes a las pistas de las filas/columnas, y la longitud de las filas/columnas de la grilla Longitud, procesa dicha grilla completando con elementos atómicos ("#" o "X") aquellas filas/columnas que se pueden completar en una movida (ver aclaración del inicio)
 */

/* 
Caso base: No hay pistas ni grilla para analizar.
 */
firstApproximationAux([], [], _, []).

/* 
Caso Recursivo 1: Si hay pistas P para analizar, y la grilla G tiene al menos una fila, si ésta es cauta, entonces se procede a generar las soluciones cautas para dicha fila y a seguir analizando la grilla G' y las pistas P', donde G' y P' son la grilla y la lista de pistas sin su primer elemento, respectivamente
Caso Recursivo 2: Si la grilla G tiene al menos una fila y ésta no es cauta, entonces se ignora y se procede a seguir analizando con el resto de las filas de G.
 */
firstApproximationAux([FG|FGs], [P|Ps], Longitud, [FS|FSs]):-
	esListaCauta(P, FG),
	generarSolucionesCautas(FG, P, Longitud, FS),
	firstApproximationAux(FGs, Ps, Longitud, FSs).

firstApproximationAux([_F|FGs], [_P|Ps], Longitud, [_F|FSs]):-
	firstApproximationAux(FGs, Ps, Longitud, FSs).

/* 
completarListasCautas(+Grilla, +Pistas, +Longitud, -GrillaResultado)
Se encarga de procesar la Grilla dada en base a las Pistas y a la Longitud dadas, rellenando aquellas celdas de las filas/columnas (funciona igual para ambas) que sí o sí deben ir pintadas, gracias a la resolución lógica vía intersección de posibles soluciones para una lista (ver el predicado generarSolucionesCautas y aclaración del inicio)
 */

/* 
Caso base: No hay Grilla ni Pistas para analizar
 */
completarListasCautas([], [], _, []).

/* 
Caso recursivo: dada una grilla Grilla, una lista de pistas Pistas (puede ser la referida a las filas o a las columnas), la longitud de dicha lista Longitud, toma el primer elemento de Grilla y Pistas (la lista de la grilla que se está leyendo y la pista referida a esa lista, respectivamente), y la completa mediante la lógica de resolución por interseccion de posibles soluciones. Luego repite el proceso en Grilla' y Pistas', donde Grilla' y Pistas' son Grilla y Pistas sin su primer elemento.
 */
completarListasCautas([G|Gs], [P|Ps], Longitud, [FC|FCs]):-
	generarSolucionesCautas(G, P, Longitud, FC),
	completarListasCautas(Gs, Ps, Longitud, FCs).

/* 
generarSolucionesCautas(+Lista, +Pista, +Longitud, -Result)
Dada una Lista, una Pista y su Longitud, completa aquellas posiciones de Lista que sí o sí deben ser completadas de la siguiente manera:
	-Encuentra todas las formas posibles de satisfacer la Lista de acuerdo a la Pista parametrizada y las guarda en una lista de listas
	-Intersecta todas las listas para obtener una nueva lista con el resultado de la interseccion y la guarda en Result
 */
generarSolucionesCautas(L, P, Longitud, Result):-
	findall(L, (length(L, Longitud), armarListaSegunPista(P, L)), PosiblesSoluciones),
	intersect(PosiblesSoluciones, Longitud, Result).

/* 
intersect(+ListaConListas, +Longitud, -Interseccion)
Dada una lista cuyos elementos son listas, guarda en Interseccion el resultado de intersectar entre sí todas las listas elemento de la ListaConListas parametrizada.
 */
intersect(ListaConListas, Longitud, Interseccion):-
	Nth is Longitud - 1,
	intersectAux(ListaConListas, Nth, [], Interseccion).


/*
 intersectAux(+ListaConListas, +Nth, +InterseccionInicial, -InterseccionFinal)
 Guarda en InterseccionFinal el resultado del proceso de reunir los Nth-ésimos elementos de la ListaConListas en una nueva lista y evaluar si son todos atómicos (y entonces habría un elemento en común, sea "X" o "#") o no, con el fin de armar la lista de intersección.
 */

/* 
Caso base: no hay más posiciones Nth para recorrer (la última posición válida fue 0 y por la resta terminó con valor '-1').
 */
intersectAux(_, -1, Interseccion, Interseccion).

/* 
Caso recursivo 1: si la lista formada por las posiciones Nth de las listas de la ListaConPistas está compuesta por "#", entonces se agrega el elemento "#" a la intersección en la posición Nth pues esto significa que en dicha posición hay un elemento común "#" para todas las listas.
Caso recursivo 2: ídem que en CR1 con el elemento "X".
Caso recursivo 3: en caso contrario, se agrega un elemento "_" en la posición Nth de la lista IntersecciónFinal.
 */
intersectAux(ListaConListas, Nth, InterseccionInicial, InterseccionFinal):-
	findall(E, (member(L, ListaConListas), nth0(Nth, L, E)), Nths),
	allAtoms("#", Nths),
	append(["#"], InterseccionInicial, Aux),
	NthS is Nth - 1,
	intersectAux(ListaConListas, NthS, Aux, InterseccionFinal).

intersectAux(ListaConListas, Nth, InterseccionInicial, InterseccionFinal):- 
	findall(E, (member(L, ListaConListas), nth0(Nth, L, E)), Nths),
	allAtoms("X", Nths),
	append(["X"], InterseccionInicial, Aux),
	NthS is Nth - 1,
	intersectAux(ListaConListas, NthS, Aux, InterseccionFinal).

intersectAux(ListaConListas, Nth, InterseccionInicial, InterseccionFinal):-
	append([_], InterseccionInicial, Aux),
	NthS is Nth - 1,
	intersectAux(ListaConListas, NthS, Aux, InterseccionFinal).

