# Princípios de cache

> Se você chegou até aqui, isso significa que você não desistiu na P2, parabéns!

Como um possível estudante de computação, você já sabe que existem diversas tecnologias possíveis para serem usadas na construção de um dispositivo de memória, e que esses dispositivos servem para persistir dados no mundo físico. Pois então, essas tecnologias diferentes resultam em caracterísitas diferentes para a memória, tomando como exemplo as memórias em disc rígidos (HDs), possuem capacidades altas por estarem armazenadas em um disco mecânico de tamanho considerável, mas velocidades baixíssimas, pelo mesmo motivo. Já as memórias RAM (DRAM ou SRAM) são construídas diretamente com transistores e capacitores, persistindo dados através de pulsos elétricos, isso resulta em velocidades muito altas, mas também em um custo de produção elevado, por isso o armazenamento total delas precisa ser restrito.

Normalmente, memórias SRAM são tão caras que usamos elas apenas em pequenas quantidades (alguns MB) como cache do processador, memórias DRAM são utilizadas como memória principal do processador (alguns GB) e por último as memórias de disco são usadas como armazenamento geral da máquina, hoje em dia sendo comuns encontramos dispositivos com Terabytes.

Quando escrevemos programas de computador, eles podem acessar todos esses níveis de memória, pagando um preço em tempo para cada nível acessado. O ideal seria que nosso programa acessasse apenas a SRAM, mas em virtude do tamanho reduzido, isso não acontece. Alguns acessos a memória principal (DRAM) não irão degradar tanto o desempenho do programa, mas acessos diretamente em disco rígido são um desastre.

Para otimizar esse uso, o critério mais simples é pensarmos que se colocarmos os dados usados com mais frequência na cache, vamos melhorar a performance dos acessos. Mas como esse critério precisa ser implementado por hardware, temos que pensar em uma técnica que não aumente muito o custo de produção e obtenha resultados satisfatórios.

## Princípios de localidade

Por mais que programas sejam distintos uns dos outros, nós conhecemos estruturas básicas que tendem a ser utilizadas na maior parte dos programas. Laços, procedimentos, estruturas de dados sequenciais e outras coisas do tipo são um padrão recorrente em códigos escritos por humanos. Usando esses conceitos, podemos pensar em heurísticas para otimizar nossos acessos de memória.

### Localidade temporal

O princípio de localidade temporal diz que se um item foi acessado agora, ele tende a ser acessado novamente em breve, com base no funcionamento de laçoes e na chamada de procedimentos.

### Localidade espacial

O principio de localidade espacial diz que itens com endereços próximos a um item referenciado agora, tendem a ser referenciados em breve. Nesse caso estamos falando de estruturas de dados sequenciais, mas também de instruções. Exatamente, instruções são salvas em memória geralmente de forma contígua e costumam ser executadas uma após a outra e portanto podemos aplicar localidade espacial para elas.  

## Hierarquia de memória

Se você lembra do que eu disse sobre vários tipos de memória serem usados na mesma máquina, pode ter se perguntando "Mas como eu não percebo isso?" afinal, você salva todas as coisas no seu HD e usa o computador sem se preocupar com o resto. A resposta pra isso está no uso de uma hierarquia de memória, onde as memórias mais menores (e mais rápidas) se encontram no topo da hierarquia, enquanto as memórias maiores (e bem lentas) ficam na base.

Com essa "pirâmide" montada, o processador começa acessando sempre a memória do topo, caso o dado requisitado não esteja nela, o acesso é passado para a memória logo abaixo dela e assim sucessivamente. Dessa forma, sempre que um dado está disponível em um nível superior nós temos uma latência muito baixa. Para o usuário isso é quase imperceptível e ele tem a sensação de que possui uma memória grande e rápida.

Claro que essa técnica possui limites, nem todos os dados e estruturas nós conseguiremos colocar em cache, nem todo programa é previsível de acordo com essa heurísitica. Mesmo assim, o ganho de performance é notável.

## Conceitos básicos

### Blocos

Para capturar a localidade espacial uma cache pode utilizar do conceito de blocos, sendo que cada bloco é uma porção de N bytes (a serem definidos pela especificação da cache). Dessa forma, pensando por exemplo numa cache a ser implementada para o MIPS 32 onde cada palavra possui 4 bytes, se quisermos implementar um bloco que busque 8 palavras de uma vez usaríamos um bloco de 32 bytes.

### Hit or miss

Dizemos que aconteceu um `hit` quando um dado requisitado pela CPU foi encontrado no nível superior de memória (típicamente a cache L1). Um `miss` é quando o dado requisitado não estava no nível superior e tivemos que descer um ou mais níveis para encontrar (perceba que o dado SEMPRE deve estar em algum nível de memória, do contrário teremos problemas bem grandes).

O CPI da máquina é afetado apenas pelo `miss`, já que quando ocorre um `hit` não perdemos ciclos. Quanto maior a taxa de `miss` de uma cache, maior será a degradação do desempenho. Quanto menor essa taxa, mais próximos estaremos do CPI ideal (que depende de outros fatores como emissão múltipla e hazards do pipeline).

### Métricas de desempenho

- Hit rate: taxa de acertos da cache (HR)

- Miss rate: taxa de erros da cache (MR)

> HR = 1 - MR

- Hit time: tempo para acessar o nível superior 

- Miss penalty: tempo para acessar o nível inferior e substituir o bloco (vai trazer o bloco do nível inferior para o superior)
    - Nesse caso, o tempo utilizado é sempre o de acesso ao nível mais baixo, então se demoramos 10 ciclos para acessar a MP e 100 para acessar o disco, dizemos que o MP no caso de acesso a disco é 100 ciclos.

## Funcionamento da cache

Até agora a gente aprendeu vários conceitos que são completamente inúteis se você não sabe a maneira como uma cache funciona, então é melhor darmos uma olhadinha nisso. Primeiro, você já sabe que a cache é uma memória, então sabe que dentro dela vamos guardar os dados que queremos ter fácil acesso. Mas como esses dados foram parar lá?

Basicamente, iniciamos a cache completamente vazia e o programa começa a rodar. O processador em algum ponto vai dizer "preciso do dado X[0]", então o controlador de cache vai verificar se esse dado está no nível superior, como definimos que a cache está vazia, obviamente ele não vai estar. Nesse caso, os dados (lembrando que vamos buscar um bloco e não apenas o dado requisitado) serão buscados no nível inferior e **copiados** para o nível superior, assim o processador consegue o acesso. Na próxima linha, o processador pode dizer "agora, preciso do dado X[1]" e como trouxemos um bloco com os próximos endereços, nosso dado estará em cache e nada mais vai precisar ser feito.

Mas assim, como que o controlador sabe se o dado está ou não na cache?

## Buscando o dado na cache

Buscar a memória toda em busca de um dado seria extremamente ineficiente, tampouco podemos utilizar busca simples por endereçamento já que isso faria com que tivessemos que usar 4GB de cache para endereçar toda a memória do MIPS 32. Uma boa solução é mapearmos eventualmente 2 ou mais valores para um mesmo espaço. Com isso, surge a ideia de mapeamento de cache, onde temos uma memória menor (a cache) capaz de guardar uma pequena fração do endereçamento de uma memória maior.

Existem diversas formas de mapear uma cache, vamos ver apenas as principais aqui.

## Mapeamento direto (ou 1-way)

Suponha que vamos dividir toda a memória em blocos de 8 bytes (duas palavras no MIPS) numerados de 0 até a quantidade de blocos na memória. Vamos fazer a mesma coisa na cache, supondo que nossa cache vai suportar 1024 blocos simultâneos. Também vamos numerar as posições conforme o número do bloco, então o bloco 0 da memória principal quando trazido para a cache ficaria na posição 0 da cache, o bloco 1 na posição 1 e assim sucessivamente. 

Isso funciona muito bem até chegarmos no bloco 1023 (que ficará na posição 1023). Mas ao passarmos para o bloco 1024, não temos uma posição imediata considerando nossa cache de 1024 posições. A solução disso é bem simples, na verdade faremos com que cada o bloco ocupe a posição `I % 1024` onde I é o número do bloco. Dessa forma, o bloco 0 e o bloco 1024 ocupariam a mesma posição (0) na cache. Por consequência, isso faz com que só possamos ter um desses 2 blocos de cada vez na cache.

Para o hardware, esse mapeamento é realizado pelos X `LSBs` do endereço recebido. Onde `X` é `log₂(N)` e `N` é a quantidade de posições da cache. Entretanto nós desconsideramos os dois primeiros bits do endereço que servem apenas para selecionar o byte dentro da palavra. Caso estejamos numa cache de 1024 blocos, usaremos 10 bits para esse mapeamento (`log₂(8) = 10`).

Com isso que a gente acabou de ver você descobre onde um dado **pode** estar na cache, mas você ainda não pode ter certeza se é realmente o dado que você ta procurando ou se é outro bloco na mesma posição. Para identificar de forma única precisamos do endereço completo, e é exatamente isso que vamos fazer. 

Continuamos na nossa suposição de uma cache com apenas 1024 posições, nela nós gastamos 10 bits do endereço para identificar em qual posição o dado pode estar, sobrando 20 bits (já que desconsideramos os 2 LSBs) que nós iremos **guardar** na cache junto com o dado, chamando essa fatia de 20 bits de `tag`.

Lembrando que além da tag, precisamos guardar os dados, portanto no nosso exemplo cada "linha" da cache teria esse formato:

| Tag     | Dados   |
| ------- | ------- |
| 20 bits | 32 bits |

E cada endereço seria decodificado como:

| Tag     | Index   | Byte offset |
| ------- | ------- | ----------- |
| 20 bits | 10 bits | 2 bits      |

Ao buscar um dado na cache, o controlador vai receber um endereços de 32 bits, ignorar 2 bits, checar os 3 próximos bits e falar "Ó, se esse dado tiver aqui ele vai estar na posição tal", depois vai ser feita uma comparação entre os primeiros 20 bits do endereço e os 20 bits da tag, caso sejam iguais o bloco estava em cache e ele pode ser mandado pro processador, caso sejam diferentes então o bloco no local é outro e temos um `miss`.

Se você achou que tinhamos chegado ao fim, achou errado otário. Precisamos pensar em como vamos inicializar a cache, um pouco mais pra cima eu disse que nossa cache era inicializada como vazia, mas pela forma que as memórias são feitas não podemos ter certeza que ao ligar uma vamos ter apenas bits "0" em todas as posições, e além disso, e se eu quisesse ter em cache o endereço `0x0000 0000` com 32 bits zero?

Pra contornar isso, vamos adicionar mais um bitzinho só em cada linha e chamar ele de bit de validade. Nosso bit de validade diz se um dado que está na cache é válido ou não (0 inválido, 1 válido) e ao iniciar uma cache nós podemos simplesmente setar todos os bits de validade para 0, a mesma coisa quando queremos resetar ou apagar um dado da cache. Atualizado o nosso modelo de linha da cache temos:

| Tag     | Dados   | Validade |
| ------- | ------- | -------- |
| 20 bits | 32 bits | 1 bit    |


### Organização do mapeamento direto

> Originalmente essa parte é explicada na AEX22 mas eu acho que ela faz muito mais sentido aqui nessa aula.

No esquema da imagem abaixo podemos ter uma ideia de como fica organizada no hardware uma cache de mapeamento direto. Logo no começo vemos o endereço quebrado em 3 partes: tag, index e byte offset. O index alimenta um decodificador que seleciona a entrada correta dentro da memória (que na imagem é representada por uma tabela gigante). Com a entrada encontrada, precisamos comparar a tag do endereço com a tag armazenada em memória usando um bloco comparador bit a bit. 

Esse bloco comparador é então ligado a uma porta `and` junto com o bit de validade. Ou seja, se e somente se as tags forem iguais e o bit de validade for 1, o sinal `hit` será transmitido como 1. Além disso, há outra saída do circuito que transmite o campo `data` da entrada da cache, nessa saída não precisamos fazer verificação nenhuma e deixamos essa responsabilidade pro circuito que for usar os dados checar a saída `hit`.

![Esquema do mapeamento direto](https://i.imgur.com/z1XhwSx.png)

### Calculando o tamanho de uma cache

Uma boa maneira de praticar pra ver se você entendeu os conceitos dessa aula é calcular total de uma cache em bits. Se quiser praticar isso, tente calcular o tamanho total de cache que usamos como exemplo. Se você tiver com preguiça de fazer isso, continua lendo aqui que eu vou generalizar o problema e depois aplicar pra cache que usamos de exemplo.

Pensando apenas na cache (ou seja, sem pensar nos controladores e componentes externos) podemos dizer que o tamanho total em bits é igual ao número de linhas multiplicado pelo tamanho de cada linha. Vamos tratar tudo como potência de dois porque isso vai simplificar bastante os cálculos (e porque o professor usou assim, então provavelmente numa prova ele pode cobrar do mesmo jeito).

Vamos considerar `2ⁿ` como a quantidade total de linhas, e `2ᵐ` como a quantidade de palavras em um bloco da cache (isso mesmo, podemos eventualmente ter mais de uma palavra por bloco da cache, apesar de no exemplo termos usado apenas uma). Com isso, já temos a primeira variável pra calcularmos o tamanho em bits: a quantidade total de linhas expressa como `2ⁿ`. Falta apenas encontrarmos uma forma de calcular o tamanho de uma linha e chegamos no resultado final.

Pensa aqui comigo, cada linha tem um bit de validade, uma tag e os dados. O bit de validade obviamente conta como apenas um bit, mas as outras duas variáveis são, adivinha só, variáveis. 

Vamos começar calculando a tag. Sabemos que ela é menor do que o endereço (que nesse caso possui 32 bits), além disso sabemos que precisam ser subtraídos os bits do índice (nesse caso, `n`), os bits que identificam a palavra (`m`, que são utilizados para "escolher" uma palavra no bloco) e os bits do `byte offset` (que no caso de palavras de 4 bytes, são 2). Com isso temos que a tag é `32 - n - m - 2`.

O tamanho dos dados é simplesmente dado pela quantidade de palavras (`2ᵐ`) multiplicado pelo tamanho de cada palavra em bits (32 para o MIPS32).

Juntando tudo isso, temos que o tamanho da cache dado em bits é `2ⁿ × [(2ᵐ × 32) + (32 - n - m - 2) + 1]`

### Aplicando os cálculos no nosso exemplo

Primeiro tiramos alguns dados básicos, se nossa cache tem 1024 e vamos expressar a quantidade de linhas por `2ⁿ` então:

```
1024 = 2ⁿ 
log₂(1024) = n
10 = n
```

E se temos apenas uma palavra por bloco, mas representamos a quantidade de palavras por bloco como `2ᵐ` temos que:

```
1 = 2ᵐ
log₂(1) = m
0 = m
```

Calculando a tag usando os valores para `n` e `m` que acabamos de encontrar temos:

```
tag = 32 - n - m - 2
tag = 32 - 10 - 0 - 2
tag = 20

# Sim, já tinhamos esse valor antes mas eu quis te mostrar como chegar em função de n e m
```

Juntando tudo isso na fórmula (o LC diria que isso não é uma fórmula pois ela só faz sentido pra caches de mapeamento direto. Eu digo que ela é uma fórmula que faz sentido para caches de mapeamento direto. São pontos de vistas diferentes e ele está errado).

```
2ⁿ × [(2ᵐ × 32) + (32 - n - m - 2) + 1] = Y bits na cache
2¹⁰ × [(2⁰ × 32) + (32 - 10 - 0 - 2) + 1] = Y bits na cache
1024 × [(32) + (20) + 1] = Y bits na cache
1024 × 52 = 53248 bits na cache 

(ou então podemos usar prefixos do SI e deixar simplesmente como 53 × 2¹⁰ = 53 Kilobits)
```

> Existem diversas outras maneiras para cobrar esse tipo de exercício, o enunciado poderia por exemplo, dizer apenas o total de bits de dados e te pedir para encontrar a quantidade de linhas. Entendendo os conceitos e a forma como chegamos nesses valores você pode partir de qualquer cenário desses e chegar num resultado, confie no seu potencial.