# Prova 3

## Questão 1

Um processador permite endereçar 2³² bytes. Um programa compilado para esse processador requer um espaço de endereçamento de 2³⁰ bytes. Sabe-se que o sistema de gerência de memória virtual aloca páginas somente na faixa de endereços correspondente aos primeiros 2147483648 bytes da memória física (o resto da memória é usado para outros propósitos como, por exemplo, manter a tabela de páginas). Sabe-se que o tamanho de página adotado é de 16384 bytes. Suponha que se use o mínimo número de bytes para acomodar uma entrada da tabela de páginas (não se esqueça que esse número precisa ser inteiro). Sabe-se que são necessários 3 bits para codificar o estado de uma página.

Nestas condições, quantos bytes são necessários para armazenar a tabela de páginas desse programa?

### Resolução

Primeiro, entendemos que vamos fazer uma tradução de um endereço virtual de 30 bits para um endereço físico de 32 bits.

Depois podemos obter o _page offset_ a partir do tamanho da página, fazendo log₂(_page size_) ou log₂(16384) e vamos descobrir que precisamos de 14 bits para _page offset_.

Tendo o tamanho de 30 bits para o endereço virtual e 14 bits para o _page offset_ sobram 16 bits para o _physical page number_, entretanto como o endereço final é de 32 bits, precisamos adicionar mais 2 bits a essa conta, totalizando 18 bits para o _physical page number_. Além disso, o problema nos diz que temos 3 bits de estado para cada entrada da tabela, então chegamos a um total de 21 bits por entrada. Como o valor pedido é em bytes, podemos fazer 21 bits caber em um espaço de 3 bytes.

Como o _virtual page number_ é representado com 16 bits da pra supor que eu temos 2¹⁶ páginas

`2¹⁶ entrada/tabela * 3 bytes/entrada` = **196608 bytes/tabela**

## Questão 2

Lembre que o MIPS usa um pipeline de 5 estágios (IF, ID, EX, ME, WB), que permite a escrita e a leitura de registradores em semiciclos distintos de um mesmo ciclo. Suponha que o pipeline original seja assim modificado:

- O estágio IF foi particionado em dois estágios IF1 e IF2, separados por uma barreira temporal (o primeiro acomoda o decodificador de endereços e o segundo as células de memória). Isto permite que o endereço de uma instrução seja decodificado em paralelo com o acesso (em memória) à instrução cujo endereço foi decodificado no ciclo anterior.

- O estágio ME foi particionado em dois estágios ME1 e ME2, separados por uma barreira temporal (o primeiro acomoda o decodificador de endereços e o segundo as células de memória). Isto permite que o endereço de um dado seja decodificado em paralelo com o acesso (em memória) ao dado cujo endereço foi decodificado no ciclo anterior.

Sabe-se que o hardware faz previsão estática sob a hipótese de desvio não tomado e é capaz de anular instruções que tenham sido buscadas indevidamente. Sabe-se que o endereço-alvo de um desvio condicional está disponível na saída do estágio ID (ao final do ciclo).

Sabe-se também que o resultado do teste de um desvio condicional está disponível na saída da ALU (ao final do ciclo), permitindo a busca da instrução-alvo no ciclo seguinte.

Um programa, cujas percentagens de instruções executadas são mostradas na tabela abaixo, resulta numa precisão de 75% para as previsões de desvios e numa taxa de faltas de 10% na cache de dados. A penalidade de falta no acesso à cache de dados é 10 ciclos. 

Suponha: 
1. emissão dinâmica de até uma instrução por ciclo.
2. não ocorrem hazards estruturais nem hazards de dados.
3. a taxa de faltas na cache de instruções é zero.

![](https://imgur.com/GBix2VP.png)

Nestas condições, o número médio de ciclos por instrução ao se executar esse programa é: 

### Resolução

Pelos dados do pipeline passados no exercício, podemos fazer um diagrama de pipeline para descobrir o atraso gerado por um erro no sistema de previsão de branches, fazendo isso obtemos que a penalidade é de 3 ciclos.

O próprio problema nos diz que temos 25% de branches e que dessas instruções 25% das previsão resultam em erro, como também descobrimos que a penalidade é de 3 ciclos, já temos o valor médio de ciclos de parada devido a faltas no previsor de branch.

Agora, passando as faltas de cache, temos 30% de loads, 10% de store, um total de 40% de acessos a memória. O problema diz que a taxa de falhas da cache é de 10% e a penalidade de 10 ciclos. Com isso também temos o valor médio de ciclos de parada devido a faltas na cache. Pra finalizar, só aplicar isso na fórmula `CPI Médio = CPI Base + CPI Stalls` supondo um CPI Base = 1.

```
CPI Médio = 1 + (% Branches * MR Branches * Penalidade de branches) + (LS% * MRL1 + MP)
          = 1 + (0.25 * 0.25 * 3) + (0.4 * 0.1 * 10)
          = 1 + 0.1875 + 0.4
          = 1.5785
```

### Resolução

## Questão 3

Um processador usa endereços de 32 bits e uma pequena cache de mapeamento direto. A Tabela abaixo mostra uma sequência de referências à memória em ordem temporal (de cima para baixo). Cada linha da tabela representa os 16 bits menos significativos de um endereço referenciado, sendo que os 16 bits mais significativos são todos zeros. Sabe-se que a cache tem capacidade para armazenar apenas 4 blocos de memória e que cada bloco ocupa 8 bytes.

![Tabela de endereços](https://imgur.com/TLCPR39.png)

Nestas condições, responda:

O número de acessos à memória que resultam em acertos em cache é: [2]

O número de acessos à memória que resultam em substituição de bloco em cache é: [7]

### Resolução

Os 2 primeiros bits serão utilizados como byte offset, mas nesse caso sempre serão  0 0 para pegar o primeiro byte de uma palavra. Logo em seguida, viria o _word offset_, como sabemos que cada bloco ocupa 8 bytes e temos palavras de 4 bytes, podemos inferir que são 2 palavras por bloco, então usaremos apenas um bit para o _word offset_. Também temos a informação de que a cache possui apenas 4 blocos de memória, então usaremos 2 bits para representar o index, por último sobram 11 bits para representar a tag.

Estrutura de um endereço: `[tag]¹¹ [index]² [word offset]¹ [byte offset]²`

```
[0 0 0 0 0 0 0 0 0 0 0] [0 1] [1] [0 0].
[0 0 0 0 0 0 1 0 1 1 0] [1 0] [0] [0 0].
[0 0 0 0 0 0 0 0 1 0 1] [0 1] [1] [0 0].
[0 0 0 0 0 0 0 0 0 0 0] [0 1] [0] [0 0].
[0 0 0 0 0 0 1 0 1 1 1] [1 1] [1] [0 0].
[0 0 0 0 0 0 0 1 0 1 1] [0 0] [0] [0 0].
[0 0 0 0 0 0 1 0 1 1 1] [1 1] [0] [0 0].
[0 0 0 0 0 0 0 0 0 0 1] [1 1] [0] [0 0].
[0 0 0 0 0 0 1 0 1 1 0] [1 0] [1] [0 0].
[0 0 0 0 0 0 0 0 1 0 1] [1 0] [0] [0 0].
[0 0 0 0 0 0 1 0 1 1 1] [0 1] [0] [0 0]
[0 0 0 0 0 0 1 1 1 1 1] [1 0] [1] [0 0]
[0 0 0 0 0 0 0 0 1 0 1] [0 1] [0] [0 0]
```

Acessos: 

1. Tag: `[0 0 0 0 0 0 0 0 0 0 0]`, Index: `[0 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, não tem nada naquele lugar da cache ainda, carrega o bloco no espaço 1.

2. Tag: `[0 0 0 0 0 0 1 0 1 1 0]`, Index: `[1 0]`, Palavra `[1]`, Byte `[0 0]`

Miss, não tem nada naquele lugar da cache ainda, carrega o bloco no espaço 2.

3. Tag: `[0 0 0 0 0 0 0 0 1 0 1]`, Index: `[0 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 1.

4. Tag: `[0 0 0 0 0 0 0 0 0 0 0]`, Index: `[0 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 1.

5. Tag: `[0 0 0 0 0 0 1 0 1 1 1]`, Index: `[1 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, não tem nada naquele lugar da cache ainda, carrega o bloco no espaço 3.

6. Tag: `[0 0 0 0 0 0 0 1 0 1 1]`, Index: `[0 0]`, Palavra `[0]`, Byte `[0 0]`

Miss, não tem nada naquele lugar da cache ainda, carrega o bloco no espaço 0.

7. Tag: `[0 0 0 0 0 0 1 0 1 1 1]`, Index: `[1 1]`, Palavra `[0]`, Byte `[0 0]`

Hit, tag bate com o bloco que estava no local, mesmo que palavra seja diferente, ela ainda estava carregada no mesmo bloco.

8. Tag: `[0 0 0 0 0 0 0 0 0 0 1]`, Index: `[1 1]`, Palavra `[0]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 3.

9. Tag: `[0 0 0 0 0 0 1 0 1 1 0]`, Index: `[1 0]`, Palavra `[1]`, Byte `[0 0]`

Hit, tag bate com o bloco que estava no local, mesmo que palavra seja diferente, ela ainda estava carregada no mesmo bloco.

10. Tag: `[0 0 0 0 0 0 0 0 1 0 1]`, Index: `[1 0]`, Palavra `[0]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 2.

11. Tag: `[0 0 0 0 0 0 1 0 1 1 1]`, Index: `[0 1]`, Palavra `[0]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 1.

12. Tag: `[0 0 0 0 0 0 1 1 1 1 1]`, Index: `[0 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 1.

13. Tag: `[0 0 0 0 0 0 0 0 1 0 1]`, Index: `[1 1]`, Palavra `[0]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 3.

Resultado final: 7 subs, 2 hits, 11 miss.

## Questão 4 

A instrução `beq $s1, $s2, label` reside no endereço `0x 0FF9 0014`. Para o MIPS32, qual o endereço-efetivo mínimo atingível por esta instrução?

### Resolução

Considerando um MIPS32, o endereço mínimo atingível por uma instrução BEQ é o menor número negativo representável por 16 bits com complemento de 2. Nesse caso, 0x1FFFC.

`0x0FF9 0014 - 0x1FFFC = 0x0FF7 0018`

## Questão 5

A figura abaixo mostra a ordem temporal em que as instruções de um programa paralelo são executadas num dual-core, onde X e Y são endereços de variáveis compartilhadas e as reticências representam instruções aritméticas. Cada núcleo tem suas próprias caches de dados e instruções (separadas). Há um único nível de cache.  Todas as caches de dados têm blocos de 256 bytes e usam write allocate. O protocolo de coerência codifica cada estado em dois bits: bit de validade e dirty bit. Nestas condições, para os eventos induzidos pelo trecho observado do programa, qual(is) das seguintes afirmações é (são) verdadeira(s)?

![](https://imgur.com/CfMLIgu.png)

Cenário 1: X = 0xBBBBBBCA; Y = 0xBBBBBBC0

Cenário 2: X = 0xAAAAAADC; Y = 0xCCCCCCDC

- [ ] No Cenário 1, o número total de acertos nas caches de dados é 2.
- [ ] No Cenário 1, o número total de acertos nas caches de dados é 3.
- [ ] No Cenário 1, o número total de leituras da memória principal é 1.
- [ ] No Cenário 1, o número total de leituras da memória principal é 2.
- [ ] No Cenário 1, o número total de escritas na memória principal é 0.
- [ ] No Cenário 1, o número total de escritas na memória principal é 1.
- [ ] No Cenário 1, o número total de escritas na memória principal é 2.
- [ ] No Cenário 2, o número total de acertos nas caches de dados é 2.
- [ ] No Cenário 2, o número total de acertos nas caches de dados é 3.
- [ ] No Cenário 2, o número total de leituras da memória principal é 1.
- [ ] No Cenário 2, o número total de leituras da memória principal é 2.
- [ ] No Cenário 2, o número total de escritas na memória principal é 0.
- [ ] No Cenário 2, o número total de escritas na memória principal é 1.
- [ ] No Cenário 2, o número total de escritas na memória principal é 2.

## Questão 6

Um processador adota uma hierarquia de memória com dois níveis de cache e a memória principal (MP). No primeiro nível, há uma cache de instruções (I-L1) e uma cache de dados (D-L1) separadas. No segundo nível, há uma cache unificada para dados e instruções (L2). Os parâmetros das memórias são os seguintes:

- Acesso à MP = 100 ciclos.

- Acesso a L2 = 10 ciclos.

- Acesso a I-L1 ou D-L1: 1 ciclo.

Ao rodar nesse processador, um programa repete – um número muito grande de vezes – as instruções de um pequeno laço, de forma que a taxa de faltas em I-L1 pode ser considerada nula para fins práticos, mas o mesmo não acontece para as demais caches, como mostram as seguintes taxas de falta (expressas como números fracionários):

- Taxa de faltas no acessos a I-L1: 0,0.

- Taxa de faltas no acesso a D-L1: 0,250.

- Taxa de faltas (global) no acesso aos níveis L1 e L2: 0,125.

Sabe-se que a fração de instruções que acessam dados em memória é 1/3 e que a execução do programa requer em média 7,0 ciclos por instrução. Qual seria o número médio de ciclos por instrução nesse processador na situação em que D-L1 também exibisse taxa de faltas nula?

### Resolução

CPI[real] = LS% * MissRate[D-L1] * MissPenalty[D-L1] + LS% * MissRate[Global] * MissPenalty[MP]

7 = (1/3) * 0.25 * 10 + (1/3) * 0.125 * 100
7 = 5
2

## Questão 8 

Um single-core chip adota endereços de 32 bits e usa uma cache 1-way com capacidade de 4096 bytes de dados. Cada entrada da cache armazena um bloco de dados com 8 bytes, além dos bits necessários para codificar o estado do bloco. Sabe-se que um deles é um reference bit, que é usado para implementar um critério LRU aproximado. Sabe-se também que a cache adota a política de write-back e, portanto, requer um dirty bit. Neste cenário, qual o número total de bits requerido para implementar toda a cache?

### Resolução

O problema nos diz que temos uma cache 1-way, ou seja, mapeamento direto, por isso não precisamos nos preocupar com conjuntos. Também diz que a capacidade de armazenamento por bloco é de 8 bytes, disso conseguimos retirar a quantidade de blocos `2¹² / 2³ = 2⁹`.

Precisamos agora achar a quantidade de bits usados em cada bloco. Temos obviamente os 64 bits usados para dados, além disso o bit de validade, o bit de referência e o dirty bit. Falta apenas encontrarmos o tamanho da tag.

Tamanho da Tag  = Tamanho do endereço - Tamanho do index - Word offset - Byte offset
                = 32 - 9 - 1 - 2 = 20

Com o tamanho da tag calculado, temos um tamanho total de 64 + 3 + 20 (87) bits por bloco. Multiplicando isso pela quantidade total de blocos na cache temos 44544.