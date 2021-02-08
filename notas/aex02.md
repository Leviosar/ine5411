# Introdução a programação de sistemas

Máquinas trabalham naturalmente com números binários, então uma sequência de caracteres codificados de forma binária não é nada novo e assustador para um computador. Seres humanos por outro lado tem essa falha característica de projeto que os impede de trabalhar perfeitamente com linguagens muito diferentes da nossa escrital natural. 

Por esse motivo, a solução criada a princípio para facilitar a interface humano-máquina na programação de sistemas foi uma linguagem intermediária que comumente chamamos de Assembly. Infelizmente, mesmo essa linguagem intermediária ainda é muito verbosa e com poucos recursos de abstração, levando muito tempo para um programador escrever um código usando ela. Além disso, outro grande problema do Assembly é ser dependente da plataforma, isto é, um código do MIPS Assembly não pode de forma alguma ser interpretado por um processador x86.

Então chegamos em outra solução, como sempre os programadores e seu vício incansável por abstração tiveram a ideia de criar linguagens de alto nível, usando uma sintaxe muito mais parecida com a escrita humana, além de operadores algébricos e lógicos. Essas linguagens de alto nível são agnósticas quanto ao processador que irá executá-las e precisam de um outro software, o compilador, para transformar código de alto nível em Assembly, que depois será transformado em linguagem de máquina.

# Dois dedinho de Assembly

## Instruções

Uma instrução é um comando criado e especificado na ISA (Instruction set architecture) de um processador, elas são o bloco mais básico do Assembly e sua funcionalidade varia de instrução para instrução. Por exemplo, a instrução `add` soma o conteúdo de dois registradores, a instrução `sll` realiza uma operação de `shift left` onde um número N de bits do número é deslocado a esquerda e existem outras inúmeras instruções com outros propósitos. A sintaxe básica do MIPS Assembly para uma instrução tem a seguinte forma:

```assembly
mnemônico destino, operandos

# exemplo

add, $t0, $t0, $t1
```

Você pode estar se perguntando: o que é um mnemônico? Segundo o dicionário
>Que se refere à memória; mnêmico. Fácil de ser memorizado: sequência mnemônica.

Nesse contexto, um mnemônico então é uma palavra que vai nos referenciar a qual comando aquela instrução pertence. No exemplo anterior de código, o mnemônico `add` marca uma operação de soma. Onde os valores dos registradores `$t0` e `$t1` são somados e colocados em `$t0`.

## Diretivas

Mas nem tudo que é Assembly é instrução, também temos outras construções na linguagem, como as diretivas, que são utilizadas principalmente pelo Assembler. Uma diretiva é marcada por ser precedida no código por um `.`, como por exemplo `.text` que diz ao Assembler para adicionar aquele trecho de código ao segmento de texto do programa.

```assembly
.text
.align
.globl main

main:
    move $t0, $t1
```

## Labels

Outra construção bastante utilizada são as `labels` ou `etiquetas` (mas não fala isso por favor) que servem como valor simbólico para um endereço de memória. Já vimos um exemplo de label no código anterior, a label definida por `main:` e que é utilizada pela diretiva `.globl`. Digamos que você quer criar um loop e em cada execução ele retorna para o começo. Você pode criar uma label que aponta para o endereço do começo do loop, e na hora de pular para o endereço desejado usar apenas a label.

```assembly
.text
.align
.globl main

main:
    lw $t6, 28($sp)

loop:
    sll $t6, 1
    ble $t6, 10000, loop
```

## Pseudoinstruções

Como o nome pode sugerir, uma pseudoinstrução é basicamente uma instrução que não é uma instrução de verdade. Confuso? É. Mas formalmente, uma instrução pode ser escrita em código Assembly e não ser parte da ISA de um processador, mas sim fazer parte da especificação do próprio compilador. É mais fácil de entender com um exemplo.

A pseudoinstrução `move` transporta o valor de um registrador para outro, e por ser uma pseudoinstrução ela não existe no processador, então o compilador expande essa pseudoinstrução em uma outra instrução, dessa vez nativa, que implementa a mesma função de outra forma. Nesse caso, o compilador expandiria para um `add` entre o registrador passado e o `$zero`, registrador de utilidade que sempre possui o valor 0. As operações são equivalentes já que `x + 0 = x`.

```assembly
move $t0, $t1
# essa instrução move é expandida no add
add $t0, $t1, $zero
```

# Montador

O programa montador, ou assembler, traduz um código simbólico assembly para linguagem de máquina, expandindo pseudoinstruções, aplicando diretivas, substituindo labels por seus valores reais e traduzindo o código para binário. Entretanto, o montador não gera um arquivo final executável, mas sim algo que chamamos de "arquivo objeto". Nesse arquivo objeto, a maior parte das coisas já estão completas e em código de máquina, mas links externos para outros procedimentos ou arquivos estão faltando.

Digamos que você usou a função `printf` em um código C, ao passar o código pelo compilador, ele irá transformar em assembly, e o montador a partir desse assembly gera um arquivo objeto, mas ele não sabe ainda encontrar essas referências externas como a biblioteca `stdio` onde está o `printf`, isso como vamos ver em seguida é trabalho do ligador.

# Ligador

A maior parte dos programas que escrevemos hoje em dia é organizado em módulos, até mesmo um "Hello world!" em C provavelmente vai usar o `printf` que está na biblioteca `stdio`. Por causa dessa necessidade de resolver ligações externas, existe um programa chamado ligador, que trabalha ao final do processo de montagem do código objeto.

O ligador passa pelo código incompleto do arquivo objeto, preenchendo as referências externas que ficaram em aberto, realizando os cálculos dos endereços necessários para colocar nesses locais. Ao final da execução do ligador, temos um arquivo binário completo e executável, só esperando pelo programa carregador colocá-lo em memória para iniciar sua execução.

# Usos do Assembly

Além de servir como linguagem intermediária, existem casos onde um ser humano muito triste é obrigado a programar diretamente em Assembly, segundo as leis trabalhistas galáticas, programação Assembly constitui de um perigo a saúde física e mental do trabalhador, por isso deve se pedir adicional de insalubridade.

Existem dois casos principais onde você pode vir a ser obrigado a programar em Assembly:

- Você precisa desenvolver ou validar um novo processador ou microcontrolador que não possui ainda ferramentas modernas de compilação. Se você for esperar alguém construir um compilador (ou mesmo construir sozinho), pode atrasar muito o projeto, então escreve direto o Assembly.

- Você precisa desenvolver alguma porcaria com sistemas embarcados e processadores tão ruins que ninguém nunca pensou em construir um compilador para ele. Parabéns, você e seu processador de 5 centavos vão passar longas noites escrevendo Assembly.