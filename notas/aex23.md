# Associatividade em cache

## Mapeamento direto

Mapeia um bloco da memória principal pra uma única posição na cache.

Ao buscar um bloco na cache, usamos apenas o índice daquele bloco, vamos até a posição para a qual o índice é mapeado e simplesmente verificamos se o bloco que está lá é o correto ou não pela tag. Essa comparação é feita por um único circuito comparador pra cache toda.

## Cache totalmente associativa

Mapeia um bloco da memória principal pra **qualquer** posição da cache. Isso mesmo, ele só procura uma posição vazia (caso houver) ou a primeira posição a ter sido colocada em cache e escreve o bloco lá.

Nesse caso, precisamos "olhar" para todos as posições quando queremos procurar um bloco, passando o endereço do bloco completo para vários comparadores (específicamente um comparador para cada posição da cache) e vemos se o bloco está em cache.

> Essa organização explora bastante a localidade temporal, mas também tem um custo enorme.

## Cache associativa por conjunto

Mapeia um bloco da memória principal para um número fixo de posições na cache, sendo que essas posições formam o que chamamos de conjunto. Perceba que esse aqui é basicamente um "meio termo" entre o mapeamento direto e a cache totalmente associativa. Um nome comum para essa técnica é `n-way set-associative cache` onde `n` é substituido pelo número de posições dentro de um conjunto.

Agora, usamos o endereço do bloco para procurar em qual conjunto ele possívelmente estaria, e após isso usamos a tag para verificar se esse bloco está em alguma das posições do conjunto. Isso faz com que a gente precise de apenas um comparador pra cada posição possível de conjunto, então se temos uma `4-way set-associative cache` teremos apenas 4 comparadores.

Para encontrar a qual conjunto o nosso endereço pertence, utilizamos o operador de resto (na verdade, como já vimos antes utilizamos um deslocador) para fazer `block address % n`, onde `n` é o grau de associatividade.

> Na verdade você vai perceber que as 3 técnicas são uma única coisa, sendo que elas se baseiam no mapeamento por conjunto; O mapeamento direto seria um `1-way set-associative cache` e a cache totalmente associativa seria um `m-way set-associative cache` com `m` sendo a quantidade de posições da cache. Mexemos apenas no tamanho dos conjuntos, mas eles continuam sendo conjuntos.

# Organização geral da cache

Até o momento nós vimos modelos de organização de caches que obedeciam a uma cache específica ou a apenas um tipo de associatividade, mas assim como eu disse que as 3 técnicas de associatividade são uma única coisa, podemos generalizar os modelos que vimos para um único que contemple todo o nosso estudo até agora. Vamos primeiro pensar na estrutura geral do endereço que será inserido na cache.

| TAG | INDEX | OFFSET |
| --- | ----- | ------ |

Em qualquer organização de cache esses 3 campos estarão presentes, mesmo que possivelmente eles tenham valores nulos (0 bits). Então, pela última vez agora com todos os conhecimentos necessários vamos entender o propósito real de cada pedaço desse endereço.

### Tag

É o identificador binário de um bloco, a tag do endereço é sempre enviada para um comparador, onde vai ser comparada com a tag dos N blocos que estão nas posições possíveis da cache. No caso de um mapeamento direto temos apenas um comparador, já que existe apenas uma posição possível. No caso da cache totalmente associativa temos tantos comparadores quanto posições da cache.

### Index

É o trecho responsável por buscar as posições onde um determinado bloco pode estar guardado na cache, podemos dizer que ele sempre mapeia para o conjunto no qual o bloco pode estar, levando em consideração de que em um mapeamento direto esse conjunto é unitário e na cache totalmente associativa é o conjunto universo.

### Offset

O offset na verdade possui duas responsabilidades que se complementam, o campo pode se considerar dividido entre 2 partes menores, um `byte offset` e um `word offset`, sendo que o `byte offset` é fixo, sempre vamos ter 2 bits nesse campo para selacionar qual byte queremos (supondo uma palavra de 4 bytes), mas o `word offset` irá variar de acordo com o tamanho do **bloco**, sendo que para encontrar o tamanho do `word offset` eu posso fazer `log₂(m)` onde `m` é a quantidade de palavras por bloco. Tendo apenas uma palavra, esse campo terá 0 bits já que eu não preciso escolher qual palavra buscar.

# Desempenho da cache

Já falamos de desempenho nessa disciplina e chegamos a conclusão de que uma boa medida para o desempenho de um processador para um certo programa é o tempo de execução, que podemos calcular a partir da quantidade de ciclos executados multiplicada pelo período de relógio do processador. Agora que introduzimos o conceito de cache e principalmente falhas na cache, precisamos adicionar mais um fator nessa conta.

Além dos ciclos onde o processador trabalhou, precisamos levar em consideração também os ciclos onde o processador ficou ocioso devido a pausas por falhas de cache, esses stalls podem impactar bastante o programa e portanto devem ser contados. Não confundir com os stalls gerados por hazards no pipeline, esses também podem atrasar a execução mas por enquanto vamos nos limitar a contabilizar apenas as falhas de cache.

Então, teriamos uma nova fórmula pra calcular o tempo de execução do programa: `TEXEC = (CiclosCPU + CiclosStall) × T`, sendo que `CiclosStall` pode ser calculado com `CiclosStall = StallsLeitura + StallsEscrita`. 

#### Stalls de leitura

Os stalls na leitura são representados pela quantidade de leituras de um programa multiplicados pela taxa de erros de leitura e a penalidade de leitura. Já quando tentamos calcular os ciclos de stall na escrita caimos em problemas maiores, já que vamos depender da política de escrita do processador, além de outras particularidades do programa a ser rodado.

#### Stalls de escrita

Por exemplo, se estamos usando `write-through` com um `write-buffer` em um problema que não possui muitas escritas sequenciais então é possível que não tenhamos nenhuma penalidade, mas se o programa tiver grandes sequencias de escritas vamos cair em situações com o buffer cheio que irão pausar o processador gerando ciclos de stall. Por isso, mesmo que a gente possa ter uma estimativa baseada na mesma lógica que temos para leitura (escritas * taxa de faltas * penalidade), esse número é apenas um "chute guiado".

#### Juntando os dois acessos

Podemos criar uma métrica combinada, ainda como uma estimativa, dessa forma nós igualariamos a penalidade de escrita com a de leitura, e usariamos um `miss ratio` global que combina as taxas de erro de escrita e leitura. Esse tipo de métrica é mais preciso quando o processador utiliza `write allocate` já que nesse caso ao ter uma falha de escrita nós vamos ler da memória também, e como a maior parte dos processadores usam essa técnica é seguro dizer que provavelmente essa métrica vai ter uma boa precisão.