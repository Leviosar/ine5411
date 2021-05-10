### Explorando localidade espacial

A cache de mapeamento direto que vimos antes possuía apenas uma palavra por bloco, o que significa que ao buscar um dado na memória principal vamos trazer apenas uma palavra para a cache. Essa cache explora a localidade temporal pois um item referenciado no primeiro momento é salvo em cache prevendo que ele será referenciado novamente em breve. Mas acabamos deixando a localidade espacial de lado, afinal se eu acessar i[0] e traze-lo para a cache, ao tentar acessar i[1] eu vou precisar acessar novamente a memória principal.

Uma das formas de resolver isso é manter mais de uma palavra por bloco da cache, então por exemplo ao invés de guardar 32 bits de dados por bloco como fizemos na primeira cache, vamos guardar 512 bits (16 palavras por bloco). Esse número não é arbitrário, existem estudos focados apenas na performance de caches de diferentes tamanhos. Mais em seguida vamos ver que precisamos ter um balanço entre o tamanho de um bloco e a quantidade total de blocos na cache. Pra efeitos de exemplo, durante essa aula vamos usar essa cache com 16 palavras por bloco e 256 blocos totais.

#### Estrutura do endereço

A primeira grande mudança na estrutra e funcionamento de uma cache com mais de uma palavra por bloco é que precisaremos modificar um pouco e estrutura do nosso endereço e da decodificação em si. Novamente vamos usar um esquemático do livro para ver a organização interna de uma cache multipalavras. 

Como precisamos de alguma forma decidir qual das palavras do bloco queremos acessar, é necessário que o endereço possua uma nova seção responsável por ser o `block offset`, o tamanho desse campo é `log₂(x)` sendo que esse x é a quantidade de palavras por bloco. Então, na nossa cache de 16 palavras por bloco teremos 4 bits responsáveis por identificar a palavra dentro do bloco.

![Cache multipalavras](https://i.imgur.com/kmFsQtE.png)

Nosso endereço vai ter a seguinte forma final, com 2 bits de byte offset, 4 bits de block offset, 8 bits de index (pois temos 256 blocos na cache), e o restante (18 bits) servem para a tag. Nesse caso percebemos que a tag identifica o **bloco** e não a palavra. A principal diferença no esquemático é que temos cada palavra do bloco sendo alimentada nas entradas em um multiplexador, e o `block offset` é utilizado como a chave seletora desse multiplexador. Então por exemplo, caso o `block offset` seja `0000`, o multiplexador irá escolher a primeira palavra do bloco.

| Tag     | Index  | Block offset | Byte offset |
| ------- | ------ | ------------ | ----------- |
| 18 bits | 8 bits | 4 bits       | 2 bits      |

> Para descobrirmos a qual bloco pertence um determinado byte (e por consequência alguma palavra se você considerar o endereçamento alinhado de 4 em 4 bytes), pegamos o endereço do byte e dividimos pelo tamanho de cada bloco (em bytes!!!). Esse processo só é necessário na forma decimal (ou hexdec) do endereço, caso você esteja usando a forma binária é só pegar a região do endereço que corresponde ao index e você vai ter o número do bloco.

### Impactos de tamanho do bloco

Agora vamos voltar naquilo que eu disse sobre o tamanho de cada bloco, eu já tinha dito que não era um número arbitrário e agora vamos entender a motivação por trás dele. No livro-texto da disciplina os autores mostram um experimento, realizado com 4 caches diferentes sob o mesmo conjunto de programas teste. Esse experimento utilizou os programas do SPEC92, é importante ressaltar isso porque o tamanho optimal dos blocos é referente ao tipo de aplicação que será rodada.

![Experimento sobre impactos do tamanho de um bloco](https://i.imgur.com/lXTzfLQ.png)

Nos resultados podemos ver que o miss rate diminuí ao aumentar o tamanho total da cache (ou seja, uma cache de 4K possui miss rate maior que uma de 256k), isso era o esperado já que aumentando o tamanho total da cache vamos ter um número maior de blocos podendo ser mantidos simultâneamente, aumentando a captura de localidade temporal.

Também vemos que, ao aumentar drásticamente o número de palavras por bloco, diminuímos a eficiência da cache. Isso acontece por que sempre vamos ter um número finito de bits na nossa cache e a cada palavra que adicionamos por bloco, removemos aqueles bits do total que poderiam ser usados pra armazenar mais blocos. Com os experimentos os autores mostram que a quantidade optimal para obter a maior captura espacial sem degradar tanto a captura temporal é de 64 bytes por bloco (os 512 bits que utilizamos no nosso exemplo).

### Lidando com faltas na cache

Agora que já sabemos uma parte de como funcionam as caches, chegou a hora de entender como que esse mecanismo vai se conectar e "conversar" com o resto do nosso processador. Pelo esquemático que vimos antes das organizações de cache sabemos que existem dois sinais de saída, o sinal `data` que no caso de um acerto irá propagar os dados que estavam em cache, e o sinal `hit` que irá servir como uma flag booleana de acerto/erro da cache. 

É esse sinal `hit` que vai estar conectado diretamente ao módulo de controle do processador (tenta lembrar lá de SD sobre a divisão entre datapath e control, talvez seja uma boa dar uma revisada nisso), dizendo ao controlador se ele deve continuar a execução completamente ou se deve pausar para esperar a busca em memória.

Caso o controle detecte um `miss` (ou seja, o sinal `hit` estava com valor 0) ele deve congelar o acesso a registradores (não permite escrita nem leitura) e aguarda checando todos os ciclos o sinal `hit` para encontrar mudanças.

**Passos realizados pelo controlador de cache**:

- Envia endereço requerido para a MP
- Inicia a leitura dos dados da MP
- Espera a leitura ser finalizada
- Atualiza o bloco buscado na cache
    - Coloca o bloco buscado no campo `data`.
    - Coloca os MSBs no campo `tag`.
    - Ativa o bit de validade
- Refaz o acesso à cache, agora com o dado presente.

### Cache também escreve

Até agora falamos apenas de leituras na cache, buscando dados para serem usados em outras instruções. Mas ao utilizarmos uma arquitetura com cache, também fazemos as escritas diretamente na cache. Então ao escrever `sw $s1, $s0` você está dizendo para o processador escrever `$s1` em memória, no endereço `$s0`, mas o que realmente acontece é uma escrita em cache.

Supondo que eu tentei escrever em um bloco da cache que estava vazio, não teremos nenhum problema e eu posso só continuar a escrita normalmente. Mas caso naquele espaço da cache já exista um bloco válido eu vou causar um conflito. Existem diversas formas de resolver esse conflito e inclusive nós vamos primeiramente ignorar que um bloco sobrescrito precisa ser atualizado em memória principal.

No caso da cache de mapeamento direto, precisamos dividir esse problema em dois casos: uma cache com apenas uma palavra por bloco e uma cache com múltiplas palavras por bloco.

#### Cache de uma palavra por bloco

Vamos supor que temos duas palavras com endereços X e Y que disputam o mesmo índice na cache. Numa sequência de instruções onde eu primeiramente **escrevo** X em memória e depois **escrevo** Y em memória, o processador na verdade irá escrever o bloco X na cache e ao tentar escrever Y vai resultar em uma falha de escrita já que tinhamos um valor previamente escrito naquela posição da cache. Mas, e se X e Y forem endereços iguais? Como vamos ver daqui a pouquinho, sobrescrever um bloco é diferente de sobrescrever uma palavra.

Como nesse caso específico temos apenas uma palavra no bloco e a heurística da cache é de que sempre mantemos o último valor referenciado em cache, logo simplesmente sobrescrevemos o bloco todo (a única palavra do bloco). Isso quer dizer que em caches de uma palavra por bloco não precisamos comparar a tag do bloco que está sendo escrito com a tag do bloco que já reside em cache.

#### Cache de múltiplas palavras por bloco

Nesse segundo exemplo, vamos pensar numa cache de 4 palavras por bloco. Além disso, também vamos supor duas palavras `x` e `y` que ocupam a primeiro palavra dentro de blocos `X` e `Y` respectivamente. Na mesma sequência de código citada no exemplo acima, chegaremos em outra falha de escrita, mas dessa vez teremos que lidar de forma diferente.

Se eu simplesmente substituir a palavra, vou acabar tendo um bloco que pode não ser homogêneo (com 3 palavras pertencentes ao primeiro bloco e uma do segundo). Então eu preciso substituir o bloco completo e não apenas a palavra? Nem sempre, caso `X` e `Y` tenham o mesmo `tag` portanto sejam o mesmo bloco, você pode simplesmente substituir a palavra que está sendo escrita.

Agora, se os tags forem diferentes então é necessário buscar todo o bloco de `Y` em memória e sobrescrever o bloco por completo, e logo em seguida escrever o novo `y` na posição correta. Esse processo, chamado de **write allocate** gera uma leitura em memória principal sempre que precisar acontecer.

# Detalhes da escrita em cache

Como vimos agora, escrever na cache é mais complexo do que apenas fazer operações de leitura. Nessa aula vamos ver que existem ainda outros fatores que temos que levar em conta na escrita da cache, coisas que no final da última aula acabamos ignorando de propósito apenas para entender o `write allocate`. Essas complicações de escrita são inerentes a mecanismos de cache e podem ser mais ou menos difíceis de lidar de acordo com o processador e sistema estudado.

## Inconsistências na escrita

Vamos supor que temos apenas uma memória principal e uma cache em um computador de exemplo, e que uma palavra está alocada no endereço que está no registrador `$s0`, com o código de exemplo abaixo vamos demonstrar um problema que poderia acontecer.

```assembly
lw $s1, $s0
addi $s1, $s1, 1
sw $s1, $s0
```

Primeiramente buscamos o valor que está guardado no endereço `$s0`, caso ele já esteja em cache será pego de lá, caso não esteja então o controlador de cache busca na MP, registra em cache e devolve o valor. Depois fazemos uma operação no valor que ficou salvo no registrador `$s1` e por fim salvamos o conteúdo do registrador `$s1` na posição de memória `$s0`.

Vamos supor primeiro que a instrução store apenas escreve na cache, isso vai acarretar numa inconsistência já que agora temos um valor diferente na cache e na MP. Isso pode causar pequenos problemas em um processador single-core ou uma porradaria generalizada em um processador multi-core. Então, precisamos tentar manter esses valores coerentes de alguma forma.

Agora vem a pergunta, ao executarmos a instrução de store, o processador deve escrever o valor na cache? Na memória principal? Nas duas? A resposta é que depende do tipo de política de cache que vamos utilizar. Podemos forçar uma escrita nas duas memórias, mas isso adicionaria passos extras a cada escrita em memória o que pode degradar o desempenho. Também podemos implementar abordagens mais "inteligentes" que exigem novas heurísticas e a adição de hardware adicional. Tudo depende do projeto em questão, mas vamos ver algumas abordagem usadas a seguir.

### Write-through

Essa aqui é a mais simples, no `write-through` nós forçamos a instrução store a escrever tanto em cache quanto na MP para qualquer caso, o que significa que pra efeitos práticos toda instrução store vai ter a latência de uma instrução que precisa buscar coisas em memória principal. Essa degradação de desempenho é altíssima, fazendo com que em benchmarks como o `SPECInt2000`, desconsiderando hazards, tenhamos uma execução 10 vezes mais lenta simplesmente por isso.

Na prática o `write-through` não é utilizado sozinho, mas sim a próxima estratégia que iremos mostrar. Isso acontece porque o `write-through` faz com que o processador inteiro espere a escrita dos valores em memória principal, tornando a perda de desempenho grande demais pra ser "ignorada".

### Write-buffer

O `write-buffer` é uma solução paliativa que visa mitigar os problemas do `write-through`, nessa solução é criado um buffer dentro do processador (utilizando SRAM de acesso rápido) capaz de armazenar uma lista de pares na forma [valor, endereço], criando assim uma "fila" de escrita. O processador ao executar um store, escreve tanto na cache quanto no buffer, com a garantia de que futuramente o buffer irá fazer as escritas na memória principal.

Dessa forma, eliminamos a espera a cada escrita e temos uma diminuição na degradação do desempenho, já que o buffer vai escrever em momentos mais "oportunos", quando a escrita puder ser paralelizada a outras instruções. Ao finalizar a escrita de um valor em seu endereço na memória principal, o controlador do `write-buffer` irá limpar a entrada que acabou de escrever do buffer. 

O principal problema é que por ser construído a partir de uma SRAM, o `write-buffer` deve ser pequeno e pode encher com facilidade, quando esse buffer estiver cheio o sistema todo então entrará no mesmo estado de pausa que entraria ao ter que esperar uma escrita durante um store do `write-through`.

### Write-back

O `write-back` utiliza o conceito de `lazyness` que é muito importante em várias áreas da computação, a ideia principal é basicamente procrastinar uma tarefa até o momento onde ela se torna completamente necessária (como por exemplo estudar cache faltando 3 dias para a P3 de org). Mas como que isso se aplica pra um problema como inconsistência de escrita na cache?

Vamos pensar bem, se eu tenho um valor novo na cache e um antigo na memória principal, qual o maior problema que pode acontecer? Exatamente o que você pensou ai, se eu substituir o bloco em cache vou perder o novo valor no limbo, fazendo com que na memória principal tenha um valor desatualizado e eu não tenha mais nenhuma cópia do novo valor. Os outros cenários não seriam problemas, caso eu tente acessar o item ele estará em cache e o processador recebe o valor atualizado, caso eu tente escrever o item então o valor atualizado dele não é mais necessário pois teremos um novo.

Se meu problema é a substituição do bloco, eu posso simplesmente escrever o valor na memória principal apenas **imediatamente antes** do bloco ser substituido. Dessa forma, garanto que ao ser substituido o valor mais novo será copiado para a memória principal e possa ser utilizado no futuro sem problemas.

As principais vantagens do `write-back` são a diminuição dos acessos de escrita em memória (já que ele vai escrever na MP apenas quando for estritamente necessário) e um menor consumo de energia que acontece também em decorrência da menor quantidade de acessos de escrita.

Infelizmente toda solução tem suas desvantagens e o `write-back` não é diferente, nesse caso os problemas estão relacionados complexidade de implementação, inconsistências em multi-cores e até um possível desempenho inferior ao `write-buffer`. 

#### Complexidade de implementação

Para implementar o `write-back` geralmente é usado um novo bit de estado na entrada da cache, chamado de `dirty bit`, que identifica se aquela entrada foi alterada ou não, dessa forma ao substituir um bloco na cache nós verificamos o `dirty bit` do bloco, caso seja 1 significa que ele precisa ser atualizado na MP. Você já deve ter percebido que isso vai adicionar complexidade no hardware e um preço extra.

#### Comparação de desempenho

Nenhuma das duas abordagens pode ser considerada universalmente mais performática, e é bem claro quando usar cada uma. O `write-through` combinado com `write-buffer` NUNCA vai gerar pausas enquanto o buffer não estiver cheio, então basicamente se o seu programa não estourar o buffer com frequência, seu código vai ser mais performático nessa abordagem. Caso o código tenha muitas escritas subsequentes ou o buffer usado seja muito pequeno, é mais provável que o buffer estoure e gera uma pausa, nesse caso é melhor utilizar `write-back`.

> É possível combinar `write-back` com `write-buffer`, colocando as escritas do `write-back` em um buffer e diminuindo mais ainda a chance de ter pausas na execução, entretanto essa solução combina o aumento de custo das duas soluções.

# Impactos da cache no desempenho

Pra ter qualquer tipo de discussão sobre desempenho sempre precisamos ter métricas definidas em mente, uma das primeiras métricas que aparece quando pensamos em uso de cache é a quantidade de ciclos perdidos devido faltas na cache, com esse número conseguimos medir e eficiência de uma cache comparada com outra para um certo programa ou conjunto de programas.

Podemos deduzir essa "fórmula" de forma bastante empírica, pensando que para uma quantidade `I` de instruções eu terei uma proporção `LS` de loads e stores no programa, sendo que nossa cache possui uma taxa de erros [`MR`](https://twitter.com/kaelltx/status/1215341482133114887?lang=en) e precisamos pagar uma penalidade `p` sempre que vamos buscar algo na memória principal devido a uma falta. Podemos equacionar isso da seguinte forma: `Ciclos perdidos = I * LS * MR * P`

A partir dessa métrica podemos pensar em maneiras de otimizar nossas caches, considerando que o nosso programa seja fixo (você vai ver depois que existem formas de otimizar um software sabendo o tipo de cache que o processador no qual ele vai rodar possui) podemos brincar apenas com o hardware, seja diminuindo a penalidade ou o miss rate.

Para diminuir a penalidade é necessário ou melhorar a tecnologia da memória principal ou então fazer algo que veremos futuramente, níveis de cache, onde existem diversas caches entre o processador e a MP, uma maior do que a outra.

O miss rate pode ser diminuido explorando diferentes tamanhos de bloco como vimos anteriormente, mas também podemos testar diferentes tipos de associatividade para a cache e medir os novos resultados. Associatividade são maneiras distintas de organizar uma cache, já vimos um tipo de associatividade na disciplina: mapeamento direto. Até o final vamos aprender também sobre caches com associatividade de conjuntos e caches totalmente associativas.