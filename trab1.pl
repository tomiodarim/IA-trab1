% rota(+X, +Y, -Valor, -Caminho)
rota(X, Y, Valor, Caminho) :- rota(X, Y, Valor, [], Caminho).

% condicao de parada (quando acaba a lista de nos)
% rota(+X, +Y, -Valor, +Visitado, +[X - Y])
rota(X, Y, Valor, Visitado, [X]) :-
    % se X nao esta na lista dos visitados
    \+ memberchk(X, Visitado),
    % calcular rota de X ate Y
    rota(X, Y, Valor).

% Algiritmo de Dijkstra para o menor caminho
rota(X, Z, Valor, Visitado, [X | T]) :-
    \+ memberchk(X, Visitado),
    rota(X, Y, Valor1),
    rota(Y, Z, Valor2, [X | Visitado], T),
    \+ memberchk(X, T),
    Valor is Valor1 + Valor2.

append([X|Y],Z,[X|W]) :- append(Y,Z,W).
append([],X,X).

% calcula o caminho de menor valor dados a partida e chegada
% menor_caminho(+X, +Y, ?ValorMin, -Caminho)
menor_caminho(X, Y, ValorMin, Caminho) :-
    rota(X, Y, ValorMin, Caminho), 
    \+ (rota(X, Y, ValorMenor, CaminhoAlt), 
        CaminhoAlt \= Caminho, 
        ValorMenor < ValorMin).

% printa um nó do caminho
% write_node(+Node)
write_node(Node) :-
    swritef(S, '-> %w ', [Node]),
    write(S).

% imprime na tela as informações caminho de menor valor
% trajeto_mais_economico(+Partida, +Chegada)
trajeto_mais_economico(Partida, Chegada) :-
    writeln(''),
    ( rota(Partida, _, _) -> true ; writeln('Partida não existe') ),
    ( rota(_, Chegada, _) -> true ; writeln('Chegada não nexiste') ),

    menor_caminho(Partida, Chegada, ValorTotal, Caminho),

    % printa resultados 
    write('Cidades passadas: '),
    append(Caminho, [Chegada], L),
    maplist(write_node, L),
    swritef(S, '\n%w%d', ['Valor total: R$', ValorTotal]), writeln(S).

:- initialization(main, main).
% main(+Argv)
main(Argv) :-
    % lê arquivo de rotas
    current_prolog_flag(argv, Argv), append(_, [PathsFile], Argv),
    ensure_loaded(PathsFile),

    % lê nos de partida e chegada
    writeln('Cidade inicial: '), read(Partida),
    writeln('Cidade final: '), read(Chegada),

    % calcula caminho com menor preço
    trajeto_mais_economico(Partida, Chegada),

    nl, halt.
