/**
 * concatena(+Lista1, +Lista2, ?ResultList)
 *
 * Concatenas duas listas formando uma resultante com todos os itens
 * 
 * @param Lista1 Lista a ser concatenada.
 * @param Lista2 Lista a ser concatenada.
 * @param ResultList Lista resultante da concatenação de List1 e List2.
 */
concatena([X|Y],Z,[X|W]) :- 
    concatena(Y,Z,W).

/**
 * concatena(+List, +Element, ?ResultList)
 * concatena(?List, ?List, ?List)
 *
 * Caso base: Verdadeiro se ResultList é a concatenação da lista vazia com List.
 * Caso geral: Verdadeiro se ResultList é a concatenação da cabeça de List com a lista W,
 *             onde W é a concatenação da cauda de List com Element.
 * 
 * @param List Lista a ser concatenada.
 * @param Element Elemento a ser adicionado à lista.
 * @param ResultList Lista resultante da concatenação de List e Element.
 */
concatena([],X,X).

/**
 * rota(+X, +Y, -Valor, -Caminho)
 *
 * Caso base para situcao onde cidade de partida eh igual a cidade de chegada,
 * nesse caso o valor eh 0.
 * 
 * @param X Cidade de partida.
 * @param Y Cidade de chegada.
 * @param Valor Custo total da rota.
 * @param Caminho Lista de cidades na rota.
 */
rota(X, X, 0, []).

/**
 * rota(+X, +Y, -Valor, -Caminho)
 *
 * Predicado auxiliar para iniciar o calculo do menor caminho de X até Y
 * 
 * @param X Cidade de partida.
 * @param Y Cidade de chegada.
 * @param Valor Custo total da rota.
 * @param Caminho Lista de cidades na rota.
 */
rota(X, Y, Valor, Caminho) :- rota(X, Y, Valor, [], Caminho).

/**
 * rota(+X, +Y, -Valor, +Visitado, +[X - Y])
 *
 * Predicado que serve como condição de parada se Caminho é uma rota de X até Y e X não está na lista de Visitado.
 * 
 * @param X Cidade de partida.
 * @param Y Cidade de chegada.
 * @param Valor Custo total da rota.
 * @param Visitado Lista de cidades visitadas.
 * @param Caminho Lista de cidades na rota.
 */
rota(X, Y, Valor, Visitado, [X]) :-
    % se X nao esta na lista dos visitados
    \+ memberchk(X, Visitado),
    % calcular rota de X ate Y
    rota(X, Y, Valor).

/**
 * rota(+X, +Z, -Valor, +Visitado, +Caminho)
 *
 * Implementacao do algoritmo de Dijkstra para encontrar o menor caminho de X até Z.
 * 
 * @param X Cidade de partida.
 * @param Z Cidade de chegada.
 * @param Valor Custo total da rota.
 * @param Visitado Lista de cidades visitadas.
 * @param Caminho Lista de cidades na rota.
 */
rota(X, Z, Valor, Visitado, [X | U]) :-
    \+ memberchk(X, Visitado),
    rota(X, Y, Valor1),
    rota(Y, Z, Valor2, [X | Visitado], U),
    \+ memberchk(X, U),
    Valor is Valor1 + Valor2.

/**
 * menor_caminho(+X, +Y, ?ValorMin, -Caminho)
 *
 * Verdadeiro se Caminho é um dos caminhos de menor valor de X até Y, e ValorMin é o custo total do menor caminho.
 * 
 * @param X Cidade de partida.
 * @param Y Cidade de chegada.
 * @param ValorMin Custo total do menor caminho.
 * @param Caminho Lista de cidades no menor caminho.
 */
menor_caminho(X, Y, ValorMin, Caminho) :-
    rota(X, Y, ValorMin, Caminho), 
    \+ (rota(X, Y, ValorMenor, CaminhoAlt), 
        CaminhoAlt \= Caminho, 
        ValorMenor < ValorMin).

/**
 * exibe_no(+No, +EhUltimo)
 *
 * Imprime um nó do caminho, adicionando uma quebra de linha se for o último nó.
 * 
 * @param No Nó a ser impresso.
 * @param EhUltimo Indica se é o último nó no caminho.
 */
exibe_no(No, EhUltimo) :-
    (EhUltimo -> swritef(S, '%w \n', [No]) ; swritef(S, '%w -> ', [No])),
    write(S).

/**
 * exibe_todos_nos(+ListaNo)
 *
 * Imprime a lista de nós com tratamento adequado para o último nó.
 * 
 * @param ListaNo Lista de nós a ser impressa.
 */
exibe_todos_nos([No]) :- exibe_no(No, true).
exibe_todos_nos([No|Rest]) :- exibe_no(No, false), exibe_todos_nos(Rest).

/**
 * trajeto_mais_economico(+Partida, +Chegada)
 *
 * Calcula e imprime o caminho de menor valor entre a cidade de Partida e a cidade de Chegada.
 * 
 * @param Partida Cidade de partida.
 * @param Chegada Cidade de chegada.
 */
trajeto_mais_economico(Partida, Chegada) :-
    writeln(''),
    ( rota(Partida, _, _) -> true ; writeln('Partida não existe') ),
    ( rota(_, Chegada, _) -> true ; writeln('Chegada não existe') ),

    menor_caminho(Partida, Chegada, ValorTotal, Caminho),
    concatena(Caminho, [Chegada], L),

    % exibe resultados 
    write('Cidades passadas: '),
    exibe_todos_nos(L),
    swritef(S, '%w%d', ['Valor total: R$', ValorTotal]), writeln(S).

% Inicia com predicado main como objetivo principal, caso o predicado falhe um erro eh disparado
:- initialization(main, main).

/**
 * main(+Argv)
 *
 * Função principal que é executada ao iniciar o programa.
 * 
 * @param Argv Lista de argumentos passados na linha de comando.
 */
main(Argv) :-
    % Extrai a lista de argumentos para a variavel Argv
    current_prolog_flag(argv, Argv), 
    (

        % Verifica se apenas 1 argumento foi passado
        length(Argv, 1) ->
        % Extrai o argumento para a variavel PathsFile
        Argv = [PathsFile];
        % Exibe mensagem e interrompe caso o numero de parametros seja invalido
        writeln('Error: O programa espera exatamente 1 argumento sendo o arquivo de rotas!'),
        halt(1)
    ),
    % Carrega predicados de rotas presentes no arquivo
    ensure_loaded(PathsFile),

    % Requisita ao usuario os de partida e chegada
    writeln('Cidade inicial: '), read(Partida),
    writeln('Cidade final: '), read(Chegada),

    % calcula caminho com menor preço
    trajeto_mais_economico(Partida, Chegada),

    nl, halt.