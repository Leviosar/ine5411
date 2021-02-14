# Instruction set architecture (ISA)

A ISA é um modelo abstrato e teórico de um processador, ela determina quais são as instruções que um processador é capaz de executar, o formato binário dessas instruções e algumas outras definições de implementação. Todo processador precisa implementar uma ISA e processadores diferentes podem implementar a mesma ISA.

Como exemplos de ISA, temos:

| ISA    | Processadores               |
| ------ | --------------------------- |
| ARM v7 | Cortex-A, Cortex-M          |
| ARM v8 | ARM Neoverse                |
| x86    | Intel i3, i5, i7, AMD Ryzen |
| MIPS   | R12000                      |

Nessa disciplina, a ISA escolhida para servir de exemplo nas aulas e nas atividades é o MIPS32, uma ISA de propósitos gerais e com registradores de 32 bits que implementa a filosfia **RISC**.

## RISC

_Reduced instruction set computer_ ou _RISC_ é o nome dado a ISAs que seguem a filosofia de possuir uma quantidade menor de instruções muito otimizadas e genéricas ao invés de uma grande quantidade de instruções específicas com menos otimizações. Essa abordagem é contrária à utilizada pela arquitetura x86.

Esses princípios _RISC_ seguidos pelo MIPS acarretam em algumas consequências importantes, vamos listar alguns.

### Suporte para operadores fixos

As operações aritméticas no MIPS possuem sempre 2 operandos e um destino, como você já pode ter visto na instrução `add $s0, $s0, $s1` o destino sempre estará a esquerda, enquanto os operandos a direita. Um registrador pode ser ao mesmo tempo destino e operando, nesse caso o resultado será sobrescrito no valor antigo do registrador.

Caso queiramos implementar uma soma de 3 variáveis, `a = b + c + d` precisamos quebrar essa operação e usar valores temporários, como o código assembly abaixo:

```assembly
# [a, b, c, d] = [$s1, $s2, $s3, $s4]
add $t0, $s2, $s3
add $s1, $t0, $s4
```

Em um processador _CISC_ (_complex instruction set computer_) poderíamos ter além da instrução `add destino, fonte, fonte` uma outra do tipo `add destino, fonte, fonte, fonte` para realizar operações com 3 operandos.

Esse princípio favorece a simplicidade, tanto no hardware quanto no software. No caso do hardware, precisamos de uma única ALU com duas entradas, no caso de processadores x86 podemos ter diversas ALUs com tamanhos diferentes. Já na parte software, optar por uma quantidade fixa de operandos reduz a quantidade de decisões que um compilador precisará tomar na hora de gerar código.

### Banco de registradores

O MIPS possui um banco de registradores enxuto, com apenas 32 registradores de propósitos gerais, sendo que alguns deles não podem ser alocados pelo assembler pois são reservados para outros propósitos. Essa aparente escassez de registradores é necessária porque quanto mais registradores um processador possuir, maior o seu tamanho físico, o que aumenta a temperatura gerada pelo processador em execução. Como você deve saber, existe uma barreira física de temperatura que podemos atingir sem explodir tudo, por isso ao aumentar o número de registradores você estaria indiretamente forçando o processador a rodar em uma frequência menor.


| Número      | Simbólico   | Uso                                            |
| ----------- | ----------- | ---------------------------------------------- |
| $0          | $zero       | Constante 0                                    |
| $1          | $at         | Reservado para o montador                      |
| $2          | $v0         | Avaliação de expressões e resultado de funções |
| $3          | $v1         | Avaliação de expressões e resultado de funções |
| $4 até $7   | $a0 até $a3 | Argumentos                                     |
| $8 até $15  | $t0 até $t7 | Temporários                                    |
| $16 até $23 | $s0 até $s7 | Salvos                                         |
| $24 e $25   | $t8 e $t9   | Temporários                                    |
| $26 e $27   | $k0 e $k1   | Reservados para o SO                           |
| $28         | $gp         | Global pointer                                 |
| $29         | $sp         | Stack pointer                                  |
| $30         | $fp         | Frame pointer                                  |
| $31         | $ra         | Return address                                 |

### Máquina load/store

Para falar sobre máquinas load/store primeiro é necessário que se tenha uma leve ideia de como uma memória funciona. O exemplo clássico é pensar na memória como um arranjo unidimensional (ou uma listona beeeeeem grande), onde o bloco básico de dados é denominado **palavra** (no caso do MIPS32, uma palavra são 32 bits de informação).

Cada **palavra** pode ser encontrada dentro da memória por um **endereço**, e esses endereços funcionam de forma linear e crescente, sendo assim o primeiro endereço da memória seria o endereço "0". Ainda falando do MIPS32, cada endereço corresponde a um byte, ou seja, 1/4 da palavra. Isso significa que o endereço de um dos bytes (o primeiro ou o último) da palavra que irá determinar o endereço da palavra em si. Talvez você entenda melhor no esquema abaixo.

![](https://imgur.com/zbf063g.png)

Agora que você já sabe o básico sobre memória, precisamos pensar sobre o acesso da memória, seja para leitura ou para escrita. Como no caso da memória principal o hardware está localizado fora do processador, existe uma comunicação por um barramento que irá intermediar os acessos. Entretanto, essa comunicação é consideravelmente mais lenta do que o acesso a um registrador, o que nos leva a concluir que o acesso a memória deve ser feito apenas quando não pudermos guardar os dados em registradores.

Tendo tudo isso bem construído, podemos definir uma máquina load/store como uma máquina que implementa instruções **EXCLUSIVAS** para acesso na memória e apenas essas instruções fazem os acessos. Com isso, temos o seguinte:

1. Instruções que não são load/store devem buscar seus operandos em registradores
2. Se uma instrução aritmética precisa alterar um elemento de estrutura de dados, esse elemento deve ser carregado em registrador previamente.

Isso simplifica o compilador, fazendo com que existam menos possibilidades diferentes de geração de código para uma máquina load/store.

### Tamanhos diferentes de dados e endereçamento de palavrars

Como eu disse antes, no MIPS temos palavras de 32 bits que podem ser divididas em até 4 bytes com 4 endereços diferentes. O que significa que por exemplo se temos um ponteiro no endereço `0x00000000` e queremos acessar a próxima palavra, temos que incrementar esse ponteiro para `0x00000004`. Mas como decidimos se o endereço da palavra será definido pelo seu primeiro ou último byte? Bom, na verdade existem máquinas que fazem das duas formas e o nome desse conceito é `endianess`.

- **Little endian**: utiliza o endereço do byte menos significativo (lsb), os processadores da arquitetura x86 são um exemplo de little endian.

- **Big endian**: utiliza o endereço do byte mais significativo (msb), o MIPS32 é uma ISA big endian, mas o simulador que utilizamos na disciplina (MARS) utiliza o endereçamento da máquina hospedeira, então se você rodar ele com um processador x86 ele irá se comportar como little endian.

![Esquema de endianess](https://imgur.com/wl36GCu.png)

### Alinhamento

Como temos tamanhos diferentes de dados sendo guardados na mesma memória, escolhemos o maior tamanho possível, nesse caso uma palavra, para ditar qual será o alinhamento dessa memória. Por exemplo, uma palavra que começa na posição `0x0000000` é dita alinhada pois seu endereço é múltiplo do seu tamanho em bytes (4 % 0 = 0). 

A principal consequência vinda disso é que caso você precise acessar uma palavra deslinhada na memória que está ocupando duas linhas vai precisar de duas ou mais instruções para fazer a busca.

O MIPS32 exige que instruções estejam alinhadas na memória de instruções, assim não se corre o risco de gastar ciclos extras para buscar a instrução.

![Exemplo de alinhamento](https://imgur.com/PUIuRdM.png)

### Operandos constantes

É comum em programas querermos fazer operações com constantes, um caso bem simples que posso pensar agora é um loop com controle do tipo:

```c
for (int i = 0; i <= 10; i++) {
    printf('%f', i);
}
```

Só nesse for vamos fazer 10 operações com constantes, no caso a adição `i = i + 1`. Existem duas formas de realizarmos essa operação, a primeira é ter uma constante salva em memória onde teríamos algo do tipo `add $s0, $s0, incrementConstant`, enquanto a segunda forma adiciona as constantes direto na instrução, como `addi $s0, $s0, 1`.

Como a primeira forma utiliza uma constante em memória ou mesmo num registrador, perdemos tempo acessando esse valor. Já na segunda a constante está na própria instrução de forma numérica, então não há tempo de acesso. Hoje em dia, a grande maioria das máquinas utiliza a segunda solução para esse caso, criando operações "imediatas" para constantes.

### Instruções de tamanho fixo

Por último, vale a pena ressaltar que o MIPS possui instruções de tamanho fixo, todas elas possuem 32 bits mesmo que não usem a totalidade dos bits. Isso é feito para ter um formato consistente e auxiliar no alinhamento de instruções na memória.

## Formatos de instrução do MIPS

Como terminei a seção sobre RISC falando de instruções, chegou a hora de aprender sobre os formatos de instrução. Sim, formatos no plural, porque mesmo todas as instruções tendo o mesmo número de bits, o significado deles altera conforme o formato. Ao todo temos 3 formatos que podem ser pensados como categorias de instruções.

### Formato tipo R

Usado para algumas instruções aritméticas.

| Campo | Uso                             | Tamanho |
| ----- | ------------------------------- | ------- |
| op    | Operação a ser realizada na ULA | 6 bits  |
| rs    | Primeiro registrador fonte      | 5 bits  |
| rt    | Segundo registrador fonte       | 5 bits  |
| rd    | Registrador de destino          | 5 bits  |
| shamt | Shift amount para SLL e SLR     | 5 bits  |
| funct |                                 | 6 bits  |

![Formato tipo R](https://imgur.com/6iLmdCI.png)

### Formato tipo I

Usado para as instruções aritméticas com constante e para instruções load/store

| Campo         | Uso                                   | Tamanho |
| ------------- | ------------------------------------- | ------- |
| op            | Operação a ser realizada na ULA       | 6 bits  |
| rs            | Registrador fonte                     | 5 bits  |
| rt            | Registrador de destino                | 5 bits  |
| const/address | Constante ou endereço de deslocamento | 16 bits |

![Formato tipo I](https://imgur.com/C2w4B9x.png)