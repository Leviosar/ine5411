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

<!-- ### Cache também escreve

Até agora falamos apenas de leituras na cache, buscando dados para serem usados em outras instruções. Mas ao utilizarmos uma arquitetura com cache, também fazemos as escritas diretamente na cache. Então ao escrever `sw $s1, $s0` você está dizendo para o processador escrever `$s1` em memória, no endereço `$s0`, mas o que realmente acontece é uma escrita em cache.

Supondo que eu tentei escrever em um bloco da cache que estava vazio, não teremos nenhum problema e eu posso só continuar a escrita normalmente. Mas caso naquele -->