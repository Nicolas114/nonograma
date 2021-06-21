:- module(init, [ init/3 ]).

%tablero que se encuentra en el enunciado (pez)
/* init(
    [[2], [2, 3], [1,2], [2,4], [7], [5,2], [9], [2,5], [2,2], [2]],

    [[1,1], [3,3], [5], [1,3], [2,5,1], [9], [8], [2,2], [4], [2]],

    [
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _]
    ]
). */


/* init(
[[3], [1,2], [4], [5], [5], [3], [1,2], [4], [5], [5]], % PistasFilas

[[2], [5], [1,3], [5], [4], [3], [1,2], [4], [5], [5], [3], [1,2], [4], [5], [5]], % PistasColumnas

[["X", _ , _ , _ , _, "X", "#" , _ , _ , "#", "X", "#" , _ , _ , "#"],
["X", _ ,"X", _ , _, "X", _ , _ , _ , "#", "X", "#" , _ , _ , "#"  ],
["X", _ , _ , _ , _, "X", _ , _ , _ , "#" , "X", "#" , _ , _ , "#" ], % Grilla
["#","#","#", _ , _, "X", _ , _ , _ , "#", "X", "#" , _ , _ , "#"  ],
[ _ , _ ,"#","#","#", "X", "#" , _ , _ , "#" , "X", "#" , _ , _ , "#"],
[ _ , _ ,"#","#","#", "X", "#" , _ , _ , _ , "X", "#" , _ , _ , "#"],
[ _ , _ ,"#","X","#", "X", _ , _ , _ , _ , "X", "#" , _ , _ , "#"],
[ _ , _ ,"#",_,"#", "X", _ , _ , _ , _ , "X", "#" , _ , _ , "#"],
[ _ , _ ,"#","#","#", "X", _ , _ , _ , _ , "X", "#" , _ , _ , "#"],
[ "#" , "#" ,"#","#","#", "X", _ , _ , _ , _ , "X", "#" , _ , _ , "#"]
]
). */

%tableros auxiliares - casos de prueba durante el desarrollo

/* init(
    [[2], [1], [1]],
    [[2], [1], [1], [1], [1]],
    [[_, _, _, _, _],
    [_, _, _, _, _],
    [_, _, _, _, _]]
). */

%caso que loopea
/* init(
	[[2], [2,3], [1,2], [2,4], [7], [5,2], [9], [2,5], [2,2], [2]],	% PistasFilas
	

	[[1,1], [3,3], [5], [1,3], [2,5,1], [9], [8], [2,2], [4], [2]], 	% PistasColumnas
	

	[[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ]
	]
	).
 */

 init(
    [[2,2], [1,1], [3], [1,1], [1,1]],
    [[1], [5], [1], [5], [1]],

    [
        ["#","#",_,_,_],
        [_,_,_,_,_],
        [_,_,_,_,_],
        [_,_,_,_,_],
        [_,_,_,_,_]
    ]
 ).

/*  init(
    [[2,2], [1,1], [3], [1,1], [1,1]],
    [[1], [5], [1], [5], [1]],

    [
        [_,_,_,_,_],
        [_,_,_,_,_],
        [_,_,_,_,_],
        [_,_,_,_,_],
        [_,_,_,_,_]
    ]
 ). */
%la N
/* init(
[[1,1], [2,1], [1,1,1], [1,2], [1,1]],

[[5], [1], [1], [1], [5]],

[[_, _ , _ , _ , _ ], 		
 [_, _ ,_, _ , _ ],
 [_, _ , _ , _ , _ ],
 [_,_,_, _ , _ ],
 [_ , _ ,_,_,_]
]
). */

%[[_, _ , _ , _ , _ ], [_, _ ,_, _ , _ ], [_, _ , _ , _ , _ ], [_,_,_, _ , _ ], [_ , _ ,_,_,_]]
%trace, (solucion([[_, _], [_, _], [_, _], [_, _], [_, _], [_, _], [_, _]],[[1], [1], [1], [2], [1], [1], [2]], [[1, 5], [1, 1, 1]], X), use_rendering(table)).

/*
init(
[[2], [1,2], [4], [1], [1]],	% PistasFilas

[[2], [4], [1,3], [5], [4]], 	% PistasColumnas

[[_, "X" , "#" , _ , "X" ], 		
 ["X", "#" ,"#", "X" , "X" ],
 ["X", "#" , _ , _ , _ ],		% Grilla
 ["#","#","X", _ , _ ],
 ["X" , _ ,"#","#","#"]
]
). */