# Emissão múltipla

Existe um limite para onde podemos chegar com ILP (instruction level parallelism), quando atingimos esse limite precisamos partir pra outras técnicas, algumas opções são:

1. _Super pipelining_
    - Aumentamos o número de estágios do pipeline
    - Divide-se cada estágio em vários
    - Menor período de relógio, logo aumentamos a frequência

> Curiosidade: o pico do uso do _super pipelining_ foi no Pentium 4 que possuia aproximadamente 1823718293719273189273891723891 estágios no pipeline

2. _Multiple issue_
    - Disparamos mais instruções em cada ciclo
    - Com isso podemos ter um CPI menor do que 1

Vamos estudar no momento a segunda opção, aumentar a quantidade de instruçõs que são emitidas a cada ciclo pode aumentar drasticamente o desempenho, vamos pensar num caso simples: Intel Atom 45nm, 1,6 GHz e um pipeline de 16 estágios

Emitindo uma instrução por segundo, teremos 1,6 bilhões de instruções por segundo, com um CPI mínimo de 1. Adicionando mais uma instrução emitida a cada ciclo, vamos pra 3,2 bilhões de instruções por segundo, diminuindo nosso CPI mínimo para 0,5. Tendo até 32 instruções executadas ao mesmpo tempo!

Preste atenção, esse CPI é o mínimo, ou seja, é o desempenho máximo do hardware para um programa completamente ideal, o que basicamente não existe.

Dependendo de onde acontece a decisão de quais instruções serão emitidas a cada ciclo, criando dois tipos de emissões múltiplas: estática e dinâmica.

## Emissão múltipla estática

Acontece em tempo de compilação, com uma abordagem VLIW (Very long instruction word)

## Emissão múltipla dinâmica

Acontece em tempo de execução, com uma abordagem Superscalar

# Estágios da missão

1. Empacotamento de instruções

É o estágio que define quantas instruçõs podem ser disparadas em um dado ciclo de memória, os slots de emissão. Quando temos emissão estática, essa etapa é realizada pelo compilador, com emissão dinâmica é realizada pelo hardware em tempo de execução.

2. Manipulação de hazards

Define as ações que serão tomadas nos casos de ocorrência de hazards. Novamente, quando temos emissão estática a etapa é realizada pelo compilador, e quando temos emissão dinâmica é realizada pelo hardware em tempo de execução.

# Exemplo: emissão múltipla estática

Usando a ISA do MIPS, vamos supor uma arquitetura que emite 2 instruções paralelamente, nosso pacote precisa ter uma configuração base do tipo:

1. Primeira instrução: ALU ou desvio
2. Segunda instrução: load/store

Para buscar esse pacote paralelamente, será preciso buscar 64 bits e decodificar a instrução em par. Se uma das instruções do par não puder ser alocada, a gente precisa colocar um `nop`.

O fluxo dessa emissão de 2 instruções ficaria como na imagem a seguir:

![](https://imgur.com/PWy5PU0.png)

Mas não é simplesmente dizer que vamos fazer isso e usar o mesmo _datapath_, precisamos de mais recursos.

No primeiro estágio precisamos ser capazes de buscar 2 instruções. 

No segundo estágio, precisamos decodificar duas instruções, para isso vamos precisar de 2 módulos de controle. Além disso, como ocorre a leitura do banco de registradores, precisamos de 2 portas de acesso a esse banco.

No terceiro estágio temos o uso da ULA, que também precisará ser duplicada para suportar duas operações paralelas. 

No quarto estágio, não precisamos duplicar o número de portas da memória de dados, pois nossa restrição de pacote nos diz que a primeira instrução nunca irá usar a memória, apenas a segunda.

No quinto estágio, precisamos da possibilidade de escrever em dois registradores do banco.

Consideradas todas essas alterações, podemos agora fazer um exemplo para verificarmos a performance. Considere o seguinte código assembly:

```assembly
Loop:
    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)
    addi $s1, $s1, -4
    bne $s1, $zero, Loop
```

Em um primeiro caso, vamos olhar o número de ciclos que um _datapath_ com emissão simples

# Loop unrolling

Pensando ainda no último assembly mostrado, podemos perceber que ele representa uma iteração de loop `loop`, e se ao invés de uma iteração nós fizessemos 4 de uma vez? Isso pode nos ajudar a remover trechos de código dos extremos.

Primeiramente só replicamos o código 4 vezes:

```assembly
Loop:
    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)
    addi $s1, $s1, -4
    bne $s1, $zero, Loop
    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)
    addi $s1, $s1, -4
    bne $s1, $zero, Loop
    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)
    addi $s1, $s1, -4
    bne $s1, $zero, Loop
    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)
    addi $s1, $s1, -4
    bne $s1, $zero, Loop
```

Agora, podemos remover as checagens e `addi` intermediárias, além disso mudamos o offset do último `addi` para pular 4 posições ao invés de uma: 

```assembly
Loop:
    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)

    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)

    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)

    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)

    addi $s1, $s1, -16
    bne $s1, $zero, Loop
```

Agora chegamos num problema novo, as instruções que fazem parte do corpo do nosso loop ainda estão usando o mesmo registrador, isso causa uma dependência de nome, precisamos resolver isso:

```assembly
Loop:
    lw $t0, 0($s1)
    addu $t0, $t0, $s2
    sw $t0, 0($s1)
    
    lw $t1, 0($s1)
    addu $t1, $t1, $s2
    sw $t1, 0($s1)

    lw $t2, 0($s1)
    addu $t2, $t2, $s2
    sw $t2, 0($s1)
    
    lw $t3, 0($s1)
    addu $t3, $t3, $s2
    sw $t3, 0($s1)

    addi $s1, $s1, -16
    bne $s1, $zero, Loop
```

Agora pra compensar nossos erros de lógica dos deslocamentos, vamos passar o addi pra cima e alterar os offsets das operações store

```assembly
Loop:
    lw $t0, 0($s1)
    addi $s1, $s1, -16
    addu $t0, $t0, $s2
    sw $t0, 16($s1)

    lw $t1, 12($s1)
    addu $t1, $t1, $s2
    sw $t1, 12($s1)
    
    lw $t2, 8($s1)
    addu $t2, $t2, $s2
    sw $t2, 8($s1)
    
    lw $t3, 4($s1)
    addu $t3, $t3, $s2
    sw $t3, 4($s1)
    
    bne $s1, $zero, Loop
```

Observando o escalonamento do novo laço em uma máquina com emissão múltipla estática, vamos ter quase todos os estágios preenchidos:

![](https://imgur.com/jMOmS2S.png)

Conseguimos alocar 14 instruções em 8 ciclos, resultando em um CPI de 0,57. Um resultado muito próximo do desempenho máximo da emissão múltipla estática com 2 instruções por ciclo, que seria 0,5 CPI