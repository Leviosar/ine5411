# Políticas de atualização de cache

Caches possuem um tamanho limitado e frequentemente valores precisam ser substituidos para que a gente mantenha na cache os últimos valores acessados, explorando melhor a localidade temporal. Quando usamos apenas caches 1-way (ou mapeamento direto) não existe nenhuma dúvida sobre qual o bloco que deve ser substituido, afinal temos apenas uma posição na qual o novo bloco pode ser inserido.

Já em qualquer outro tipo de associatividade, precisamos escolher uma forma de decidir qual dos blocos vai ser substituido. O critério mais comum é o LRU (least recently used), ou seja, vamos substituir o bloco que está a mais tempo sem ser utilizado na cache. Perceba que não é o bloco a mais tempo na cache, se um bloco foi colocado a muito tempo na cache mas continua sendo acessado com frequência ele vai se manter em cache. Esse critério segue a risca a heurística da localidade temporal.

# Múltiplos níveis de cache

Em algum momento nas últimas aulas eu falei que para melhorar o desempenho de uma cache para um mesmo programa nós tinhamos duas alternativas, diminuir o `miss rate` ou diminuir a `penalidade`. Já cobrimos as maneiras de diminuir o `mr` quando falamos de associatividade, faltou então entendermos como podemos diminuir a penalidade da cache.

A primeira (e não muito útil) solução é melhorar suas memórias, diminuindo o tempo de acesso à memória principal e dessa forma fazendo com que a penalidade seja menor, essa solução possui limites bem claros, visto que a memória não pode ficar drásticamente mais rápida de uma hora pra outra. A segunda solução, bem mais complexa, é adotarmos mais de uma cache por processador, criando assim níveis de cache.

Lembram daquela hierarquia de memória que possuia as memórias menores e mais rápidas no topo enquanto as maiores e mais lentas estavam na base? Vamos adicionar mais um (ou dois) níveis naquela pirâmide. Fazendo com que ela fique como na imagem abaixo:

![Hierarquia de memória com múltiplos níveis de cache](https://i.imgur.com/t216nqD.png)

Mas, por que vamos fazer isso? Bom, na verdade tem uma boa lista de motivos. Primeiramente com esse esquema podemos otimizar nossa cache L1, fazendo com que ela seja extremamente rápida, o que vai nos custar mais, então ela precisa ser **muuuuito** pequena. Normalmente o tamanho reduzido seria um problema, pois iria aumentar levemente a nossa taxa de erros, mas nesse caso vamos ter uma cache "reserva" logo ali do lado, o que faz com que esse aumento da taxa de erros seja amortecido pela segunda cache. Além disso, com nossa cache L1 mais rápida podemos também deixar o nosso período de relógio menor, aumentando a frequência do processador.

Outro motivo é que podemos fazer com que nossa cache L2 seja consideravelmente maior, já que essa cache não vai afetar o `hit time` e vai ter um impacto reduzido na penalidade. Como a cache L2 vai ser maior, ela consegue capturar uma boa parte das coisas que a cache L1 é incapaz de fazer, portanto a taxa de faltas **global** diminui. Muita ênfase nesse global, fazendo os exercícios você vai perceber que a cache L2 possui uma taxa de faltas **local** muito alta em comparação com a L1, a razão disso é que a maior parte dos casos "fáceis" de serem capturados pelas heurísticas de localidade já são pegos na cache L1, então os casos que sobram para a cache L2 mesmo com um tamanho maior da cache podem ser problemáticos.

## Exemplo prático 

Vamos dar uma olhada no impacto de múltiplos níveis de cache com um exemplo dado pelo professor. Suponha um processador com a bizarra frequência de `5 GHz` (T = `0,2ns`), tendo uma cache L1 com `hit time = 0,2ns` e `2%` de taxa de faltas. Além disso, temos uma cache L2 com `hit time = 5ns` e que a **taxa global** de faltas do sistema com a cache L2 seja `0,5%`. O acesso a memória principal leva `100ns`. 

Por último tomaremos duas hipóteses:

1. Só faremos acessos a instruções (LS = 0%)
2. O CPI ideal do processador é 1

Faremos dois experimentos, primeiramente vamos encontrar o CPI apenas usando a cache L1, depois vamos adicionar a cache L2 e calcular o CPI usando os dois níveis, no final vamos comparar esses resultados.

#### Experimento 1

Primeiro, vamos converter os tempos das memórias para ciclos. A cache L1 possui um `hit time` igual ao período de relógio então temos apenas um ciclo no acesso dessa cache. A penalidade da memória principal é de `100ns`, dividindo pelo nosso período chegamos em exatamente `500` ciclos usados para acessos na MP. Já sabemos que a nossa taxa de faltas é 2%. Ou seja, normalmente levamos apenas 1 ciclo para executar uma instrução, mas em 2 a cada 100 instruções nós precisamos ir para a MP e pagar 500 ciclos de penalidade.

```
CPI = 1 + 0,02 × 500 = 1 + 10 = 11
```

#### Experimento 2

Agora adicionamos nossa cache L2, calculando o custo de acesso dela chegamos em 25 ciclos, não sabemos a taxa de erros local da cache L2, mas sabemos que a taxa global quando adicionamos a L2 é de `0,5%` e que a taxa de erros de L1 é `2%`. Então, normalmente levamos 1 ciclo para executar uma instrução, mas em 2 a cada 100 instruções nós recorremos para a L2, e em 0,5 a cada 100 instruções nós recorremos para a MP. Ou seja, 98% das vezes achamos o valor em L1, 1,5% achamos o valor em L2 e 0,5% o valor está na memória. Colocando as penalidades de cada memória temos a equação

```
CPI = 1 + (0,02 × 25) + (0.005 × 500)
CPI = 1 + 0,5 + 2,5 = 4
```

#### Comparando resultados

No segundo caso, tivemos um CPI quase duas vezes melhor, isso acontece porque precisamos ir bem menos vezes até a memória principal. Se antigamente iamos 2% das vezes para a MP, agora vamos apenas 0,5% das vezes, e como o acesso à MP é bem custoso, o desempenho melhora drásticamente.

## Caches multiníveis na "vida real"

O exemplo acima foi levemente exagerado, mas as caches multiníveis realmente possuem grandes impactos no desempenho, tanto é que em basicamente todos os processadores com alguma complexidade nós vemos elas presentes. Nos slides do professor tem uns dados meio desatualizados e frequentemente ele diz que apenas servidores usam 3 níveis de cache, com até 8 MB no L3. Hoje em dia processadores em desktops possuem 3 níveis de cache, com os mais modernos tendo algumas dezenas de megabytes no terceiro nível.