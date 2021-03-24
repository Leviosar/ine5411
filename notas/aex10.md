# Desempenho

Quando vamos pensar em medir o desempenho de qualquer coisa precisamos antes definir métricas e medidas, do contrário pode ser que esse cálculo se perca no caminho e não tenhamos um bom resultado. Um exemplo de forma de medir o desempenho de um computador é dar uma tarefa a dois computadores diferentes e calcular o tempo que cada um demora para finalizar essa tarefa. Mas a partir dai, precisamos de uma forma de relacionar esses dois cálculos realizados, por isso utilizamos desempenho relativo

## Desempenho relativo

Nesse mesmo cenário de duas máquinas realizando a mesma tarefa eu posso dizer: a máquina `X` é `N` vezes mais rápida do que a máquina `Y`. E para justificar essa minha afirmação posso utilizar uma fórmula do tipo

```
N = Tempo(Y) / Tempo(X)

ou

N = Desempenho(Y) / Desempenho(X)
```

Sempre tendo como base o melhor desempenho. Então, se a máquina `X` leva 4000 ms para realizar um trabalho e a máquina `Y` faz em 2000 ms eu posso dizer que baseado naquela conta, a máquina X é 2 (4000 ms / 2000 ms) vezes mais rápida.

## Medidas de desempenho

Nós podemos medir o desempenho de um PC baseado em diversas métricas, sendo que algumas serão melhores em algumas situações, outras serão melhores em geral. Para essa disciplina, vamos nos atentar apenas ao tempo desprendido em execução pelo processador, sem nos preocuparmos com interrupções de IO.

Pensando em medir apenas o desempenho da CPU podemos pensar de duas formas principais, medir o tempo de execução total ou medir a quantidade de ciclos de relógio utilizados.

## Relógio

Um processador é um sistema digital síncrono, possuindo um relógio interno que dita a execução dos ciclos, esse relógio é caracterizado por um período ou frequência. Por exemplo, vamos pensar em um relógio com período (T) de 0.25ns ou 250ps, a frequência desse relógio em GigaHertz é dada por 1/T (com T dado em nanosegundos), sendo nesse caso 1/0.25 = 4 GHz.

Sabendo quantos ciclos um programa levou pra executar e o período do relógio eu posso calcular o tempo total de execução como `TempoCPU = N × T = N / f`, onde N é o número de ciclos gastos pelo programa, T é o período do relógio e f é a frequência do relógio.

O real problema agora é entendermos como que vamos chegar nesse número de ciclos gastos.

## Ciclos de CPU

Além de decorar a equação que dá os ciclos de CPU é importante que se entenda de onde vem cada termo, assim você poderá realizar benchmarks reais retirando seus próprios dados, além de entender onde e como otimizar seu programa para reduzir o número de ciclos executados.

Vamos pensar, se eu souber exatamente quais instruções eu vou executar, e quantos ciclos elas levam, então eu tenho o número de ciclos executados na CPU, certo? Infelizmente o mundo não é tão fácil, não é possível saber exatamente quais instruções serão executadas em tempo de compilação, além de que em sistemas modernos não temos um tempo exato de ciclos que uma instrução levará para executar (você vai aprender isso em pipelines jovem gafanhoto). Portanto, como não podemos dizer com exatidão o valor de nenhum dos termos, essa equação deve ser tratada apenas como uma **estimativa**.

```
CiclosCPU = I × CPI
# I = Número de instruções
# CPI = Ciclos por instrução
```

Quando usamos essa fórmula, entendemos o CPI primeiramente como uma média de todas as instruções. Mas existem problemas que podem dizer no enunciado algo como: *dado um programa que consiste de 40% de loads e stores, sabendo que o CPI médio de uma instrução qualquer é 4, e o CPI médio de um load/store é 5, com uma quantidade arbitrária de instruções qual seria a quantidade de ciclos utilizada?*

Nesse caso, quebramos I em dois termos, primeiramente teremos `0.4 × I` representando o número total de loads e stores, e depois teremos `0.6 × I` representando o número total de outras instruções. Então baseado nos CPIs dados podemos montar a fórmula como:

```
CiclosCPU = (0.4 × I × 5) + (0.6 × I × 4)
```

### Número de instruções

Esse termo pode ser otimizado pelo processador, com escolhas mais inteligentes de instruções para certos casos. Ele só pode ser definido de verdade após executar o programa pois loops e branches podem alterar esse número baseado nos valores de entrada do programa.

### Ciclos por instrução

Esse termo pode ser otimizado apenas pelo hardware, com melhorias no pipeline ou na execução de instruções de uma forma mais rápida.

## Voltando pra nossa equação de tempo

Se agora aplicarmos o que sabemos sobre ciclos de CPU a nossa primeira equação

```
TempoCPU = I × CPI × T
```

