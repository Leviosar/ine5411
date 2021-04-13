# Capítulo 4 - The processor

### 4.8

In this exercise, we examine how pipelining aff ects the clock cycle time of the processor. Problems in this exercise assume that individual stages of the datapath have the following latencies:

| IF    | ID    | EX    | MEM   | WB    |
| ----- | ----- | ----- | ----- | ----- |
| 250ps | 350ps | 150ps | 300ps | 200ps |

Also, assume that instructions executed by the processor are broken down as follows:

| ALU | BEQ | LW  | SW  |
| --- | --- | --- | --- |
| 45% | 20% | 20% | 15% |

#### 4.8.1

What is the clock cycle time in a pipelined and non-pipelined processor?

**Resposta**:

Para um processador com pipeline, nosso caminho crítico é o estágio que leva mais tempo para ser executado, portanto seria o ID com 350ps.

Para um processador monociclo se pipeline, somamos o atraso de todos os estágios, chegando em 1250ps.

#### 4.8.2

What is the total latency of an LW instruction in a pipelined and non-pipelined processor?

**Resposta**:

Para um pipeline de 5 estágios com ciclos de 350ps, qualquer instrução quando executada de forma isolada vai possuir (5 * 350) ps de atraso, num total de 1750ps.

Para um pipeline monociclo, a latência é dada pela soma de todos os estágios que são usados pela instrução, no caso do LW ele é a instrução do caminho crítico, portanto será a soma de todos os estágios, 1250ps.

> Perceba que para uma única instrução, o pipeline se mostra menos eficiente, mas seu valor vai começar a aparecer quando vários instruções forem executadas.

#### 4.8.3

If we can split one stage of the pipelined datapath into two new stages, each with half the latency of the original stage, which stage would you split and what is the new clock cycle time of the processor?

**Resposta**

O ciclo com maior atraso, no caso ID. O novo período de relógio seria dado pelo novo ciclo mais lento, dessa vez o MEM com 300ps.

### 4.9

In this exercise, we examine how data dependences aff ect execution in the basic 5-stage pipeline described in Section 4.5. Problems in this exercise refer to the following sequence of instructions:

```
(1) or r1,r2,r3
(2) or r2,r1,r4
(3) or r1,r1,r2
```

Also, assume the following cycle times for each of the options related to forwarding:

| Without forwarding | With full forwarding | With ALU forwarding only |
| ------------------ | -------------------- | ------------------------ |
| 250ps              | 300ps                | 290ps                    |

#### 4.9.1 

Indicate dependences and their type.

**Resposta**:

Aqui precisamos de um conceito não visto muito em aula, os diferentes tipos de dependência de dados que podem ser descritos pelas siglas *RAW* (Read After Write), *RAR* (Read After Read), *WAR* (Write After Read) e *WAW* (Write After Write). No pipeline básico do MIPS de 5 estágios, as dependências do tipo *RAR*, *WAR* e *WAW* não geram nenhum hazard de dados. A única dependência que pode nos gerar algum problema nesse caso é do tipo *RAW*.

No caso do código acima, temos 5 dependências:

(2) e (3) dependem do valor de r1 calculado em (1) - Tipo *RAW*
(3) depende do valor de r2 calculado em (2) - Tipo *RAW*
(1) lê o valor de r2 que depois é escrito por (2) - Tipo *WAR*
(2) lê o valor de r1 que depois é escrito por (3) - Tipo *WAR*
(1) escreve o valor de r1 que depois é escrito por (3) - Tipo *WAW*

#### 4.9.2

Assume there is no forwarding in this pipelined processor. Indicate hazards and add nop instructions to eliminate them.

**Resposta**:

Como dito na resposta de cima, apenas dependências do tipo *RAW* podem causar hazards de dados em pipelines sem forwarding, então vamos olhar pra elas. Nesse caso, o valor está disponível no estágio WB.

**PRESTA ATENÇÃO AQUI IDIOTA: só vai estar disponível em WB pois estamos considerando um hardware onde a escrita de registradores acontece na primeira metade do ciclo, e a leitura acontece na segunda metade do ciclo, dessa forma o estágio ID pode ler o registrador que foi escrito num estágio WB paralelo a ele.**

Podemos fazer então o diagrama abaixo:

| IF  | ID  | EX  | ME  | WB  |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     | X   | X   | X   | X   | X   |     |     |     |     |     |
|     |     | X   | X   | X   | X   | X   |     |     |     |     |
|     |     |     | IF  | ID  | EX  | ME  | WB  |     |     |     |
|     |     |     |     | X   | X   | X   | X   | X   |     |     |
|     |     |     |     |     | X   | X   | X   | X   | X   |     |
|     |     |     |     |     |     | IF  | ID  | EX  | ME  | WB  |

Assim percebemos que precisamos pular 2 instruções para cada um dos dois hazards gerados pelas dependências do tipo *RAW* do código, resultando no código final:

```
(1) or r1,r2,r3
nop
nop
(2) or r2,r1,r4
nop
nop
(3) or r1,r1,r2
```

#### 4.9.3

Assume there is full forwarding in this pipelined processor. Indicate hazards and add nop instructions to eliminate them.

**Resposta**:

Agora a coisa muda, como temos forwarding completo podemos supor que a saída da ULA tem uma ligação direta com a entrada da ULA, e que o hardware do controle tem como "avisar" que a instrução deve usar o valor da saída da instrução anterior ao invés de buscar no registrador. Com isso, eliminamos os hazards que existiam no  caso anterior e podemos simplesmente prosseguir com o pipeline sem problemas.

Ou seja, o código continuará igual ao do enunciado, e o diagrama é simplesmente 3 instruções executando paralelamente sem nenhuma interrupção.

| IF  | ID  | EX  | ME  | WB  |     |     |
| --- | --- | --- | --- | --- | --- | --- |
|     | IF  | ID  | EX  | ME  | WB  |     |     
|     |     | IF  | ID  | EX  | ME  | WB  |     

#### 4.9.4

What is the total execution time of this instruction sequence without forwarding and with full forwarding? What is the speedup achieved by adding full forwarding to a pipeline that had no forwarding?

**Resposta**:

Sem forwarding, levamos 11 ciclos para executar as 3 instruções, com um relógio de 250ps (dado no enunciado) temos 11 * 250 = 2750 ps de tempo de execução.
Com forwarding, levamos 7 ciclos para executar as 3 instruções, com um relógio de 300ps (também dado no enunciado) temos 7 * 300 = 2100ps de tempo de execução.

O speedup é calculado por 2750/2100 e temos que com forwarding tivemos um desempenho aproximadamente 1.30 vezes melhor.

#### 4.9.5

Add nop instructions to this code to eliminate hazards if there is ALU-ALU forwarding only (no forwarding from the MEM to the EX stage).

**Resposta**:

No nosso caso específico (código passado no enunciado), não existem diferenças entre pra solução com full forwarding e para a solução com ALU-ALU only forwarding, isso porque nós só estamos realizando operações aritméticas, sendo que o forwarding do estágio ME para o EX seria usado caso quisessemos usar um valor buscado por uma instrução `lw`.

#### 4.9.6

What is the total execution time of this instruction sequence with only ALU-ALU forwarding? What is the speedup over a no-forwarding pipeline?

**Resposta**:

Continuamos usando os mesmos 7 ciclos da solução com full forwarding, mas dessa vez temos um período de 290ps, então o cálculo final seria 7 x 290 = 2030 ps.

E o speedup comparado a versão sem forwarding seria 2750/2030 ~= 1.35x

### 4.10

In this exercise, we examine how resource hazards, control hazards, and Instruction Set Architecture (ISA) design can aff ect pipelined execution. Problems in this exercise refer to the following fragment of MIPS code:

```assembly
sw r16, 12(r6)
lw r16, 8(r6)
beq r5, r4, Label # Assume r5!=r4
add r5, r1, r4
slt r5, r15, r4
```

Assume that individual pipeline stages have the following latencies:

| IF    | ID    | EX    | ME    | WB    |
| ----- | ----- | ----- | ----- | ----- |
| 200ps | 120ps | 150ps | 190ps | 100ps |

#### 4.10.1

For this problem, assume that all branches are perfectly predicted (this eliminates all control hazards) and that no delay slots are used. If we only have one memory (for both instructions and data), there is a structural hazard every time we need to fetch an instruction in the same cycle in which another instruction accesses data. To guarantee forward progress, this hazard must always be resolved in favor of the instruction that accesses data. What is the total execution time of this instruction sequence in the 5-stage pipeline that only has one memory? We have seen that data hazards can be eliminated by adding nops to the code. Can you do the same with this structural hazard? Why?

**Resposta**:

No diagrama de pipeline representado abaixo, um * representa um ciclo de stall, onde todo o pipeline teve que ser atrasado pois não era possível buscar a próxima instrução em memória já que um `load` ou `store` estava utilizando o barramento de memória. Os atrasos acontecem quando um `load/store` está no estágio MEM, e são hazards estruturais. O tempo de execução total foi de 2200ps (12 ciclos * 200ps de latência).

| IF  | ID  | EX  | ME  | WB  |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     | IF  | ID  | EX  | ME  | WB  |     |     |     |     |     |     |
|     |     | IF  | ID  | EX  | ME  | WB  |     |     |     |     |     |
|     |     |     | *   | *   | *   | IF  | ID  | EX  | ME  | WB  |     |
|     |     |     |     |     |     |     | IF  | ID  | EX  | ME  | WB  |

Diferentemente do hazard de dados, não podemos eliminar esse problema adicionando `nops` no pipeline, isso acontece porque o `nop` é uma instrução que deve ser buscada da memória como todas as outras e nosso problema é justamente a impossibilidade de buscar instruções.

#### 4.10.2

For this problem, assume that all branches are perfectly predicted (this eliminates all control hazards) and that no delay slots are used. If we change load/store instructions to use a register (without an off set) as the address, these instructions no longer need to use the ALU. As a result, MEM and EX stages can be overlapped and the pipeline has only 4 stages. Change this code to accommodate this changed ISA. Assuming this change does not aff ect clock cycle time, what speedup is achieved in this instruction sequence?

**Resposta**:

| IF | ID | MEX | WB |

### 4.15

The importance of having a good branch predictor depends on how often conditional branches are executed. Together with branch predictor accuracy, this will determine how much time is spent stalling due to mispredicted branches. In this exercise, assume that the breakdown of dynamic instructions into various instruction categories is as follows:

| R-Type | BEQ | JMP | LW  | SW  |
| ------ | --- | --- | --- | --- |
| 40%    | 25% | 5%  | 25% | 5%  |

Also, assume the following branch predictor accuracies:

| Always taken | Always not taken | 2-Bit |
| ------------ | ---------------- | ----- |
| 45%          | 55%              | 85%   |


#### 4.15.1

Stall cycles due to mispredicted branches increase the CPI. What is the extra CPI due to mispredicted branches with the always-taken predictor? Assume that branch outcomes are determined in the EX stage, that there are no data hazards, and that no delay slots are used.

**Resposta**:

Os fatores que vão interferir no CPI final podem ser calculados como o produto entre a quantidade de desvios, o número de ciclos perdidos a cada erro e a taxa de erros do previsor. Dessa forma temos `0.55 * 0.25 * 2 = 0.275 CPI extra`.

#### 4.15.2

Repeat 4.15.1 for the “always-not-taken” predictor

**Resposta**:

Os fatores que vão interferir no CPI final podem ser calculados como o produto entre a quantidade de desvios, o número de ciclos perdidos a cada erro e a taxa de erros do previsor. Dessa forma temos `0.45 * 0.25 * 2 = 0.225 CPI extra`.

#### 4.15.3

Repeat 4.15.1 for for the 2-bit predictor.

**Resposta**:

Os fatores que vão interferir no CPI final podem ser calculados como o produto entre a quantidade de desvios, o número de ciclos perdidos a cada erro e a taxa de erros do previsor. Dessa forma temos `0.15 * 0.25 * 2 = 0.075 CPI extra`.

### 4.18

In this exercise we compare the performance of 1-issue and 2-issue processors, taking into account program transformations that can be made to optimize for 2-issue execution. Problems in this exercise refer to the following loop (written in C):

```c
for(i = 0; i != j; i += 2) {
    b[i] = a[i] – a[i + 1];
}
```

When writing MIPS code, assume that variables are kept in registers as follows, and
that all registers except those indicated as Free are used to keep various variables,
so they cannot be used for anything else.

| i   | j   | a   | b   | c   | free             |
| --- | --- | --- | --- | --- | ---------------- |
| $r5 | $r6 | $r1 | $r2 | $r3 | $r10, $r11, $r12 |

#### 4.18.1

Translate this C code into MIPS instructions. Your translation should be direct, without rearranging instructions to achieve better performance

**Resposta**:

```assembly
    ADD $r5, $zero, $zero # i = 0
Loop:
    
    BEQ  $r5, $r6, End      # se i == j terminar o loop
    ADD  $r10, $r5, $r1     # $r10 = endereço de a[i]
    LW   $r11, 0($r10)      # $r11 = a[i]
    LW   $r10, 1($r10)      # $r10 = a[i + 1]
    SUB  $r10, $r11, $r10   # $r10 = a[i] - a[i + 1]
    ADD  $r11, $r5, $r2     # $r11 = endereço de b[i]
    SW   $r10, 0($r11)      # MEM[b [i]] = $r10
    ADDI $r5, $r5, 2        # i += 2
    BEQ  $zero, $zero, Loop # sempre volta pro começo do loop
End:
```