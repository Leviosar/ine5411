# Pipelines

O pipeline é uma técnica de paralelismo em hardware, baseada num fluxo de linha de montagem, onde existem N etapas independentes e sequenciais. Quando utilizamos essa técnica em uma CPU, separamos as etapas como partes de uma instrução, no MIPS são utilizadas 5 etapas:

1. Instruction fetch (IF)
2. Instruction decode (ID)
3. Execução: operação/cálculo de endereço (EX)
4. Acesso ao operando em memória (ME)
5. Escrita do resultado da operação no registrador (WB)

Outros processadores podem separar as instruções em números diferentes de etapas, com etapas de semânticas diferentes. O arm, por exemplo, utiliza um pipeline de 3 estágios, enquanto a bicheira do Pentium 4 usa um pipeline de 30 estágios.

A ideia geral é que enquanto uma instrução A está no estágio 2 (ID), ela já liberou o hardware necessário para o estágio 1 (IF), por isso uma segunda instrução B pode utilizar o estágio 1.

Num mundo ideal, ficaria como no seguinte diagrama:

![Pipeline de 5 estaǵios MIPS](https://imgur.com/WsAJoSJ.png)

Numa execução sequencial, 5 instruções levariam 25 ciclos de relógio pra executar, enquanto no diagrama com pipeline são apenas 9 ciclos (apesar de que como veremos depois, o ganho de ciclos não é tão perfeito e mundo ideais não existem).

## Caminho crítico em pipelines

Quando trabalhamos com um datapath monociclo, o caminho crítico é representado pelo atraso da instrução mais lenta, sendo que cada ciclo de relógio precisa durar pelo menos a duração dessa instrução.

Ao mudar pra um sistema baseado em pipelines, nosso caminho crítico passa a ser representado pelo atraso do estágio mais lento, e então cada ciclo de relógio precisa durar pelo menos a duração desse estágio.

Supondo os atrasos a seguir:

![Atrasos MIPS](https://imgur.com/78ChH2G.png)

Podemos dizer que em um datapath monociclo, o período de relógio deve ser igual ou maior que 800ps, enquanto em um datapath com pipelines precisamos de um período igual ou superior a 200ps. Para qualquer pipeline com mais de um estágio (e um pipeline de um estágio é uma coisa idiota) teremos aumento na frequência do relógio.

Ao usar pipelines, o CPI do processador tende a 1, chegando mais perto de 1 quanto mais instruções temos sendo executadas. Ao aumentar o número de instruções também aceleramos em um fator maior a execuçaõ do programa, mas não importa o quanto você aumente nunca vai chegar na acelaração ideal.

## Projetando a ISA para pipelining

### Comprimento fixo

Algumas técnicas podem nos ajudar a ter um pipeline mais eficiente e mais simples, uma delas é pensar a ISA para facilitar o pipelining, como fizeram os autores do livro texto da disciplina ao decidir usar um comprimento fixo de instrução, no caso os 32 bits da instrução do MIPS. Dessa forma o estágio IF teria sempre uma duração fixa

Outras ISAs do mercado da época utilizavam comprimentos variados, como o x86 que possuia instruções variando de 1 até 17 bytes. Com um modelo assim, o estágio IF poderia consistir de buscar 1 palavra na memória ou buscar 5 palavras, alterando a duração dele.

### Formato "fixo"

Utilizar formatos de instrução com um padrão confiável foi outra técnica utilizada pelos criadores do MIPS, obviamente as instruções não tem o MESMO formato, mas algumas coisas são iguais e ajudam no pipelining, como por exemplo a ordem dos campos das instruções do tipo R e I serem iguais.

### Máquina load/store

Como no MIPS não podemos utilizar operandos direto da memória, eles precisam ser carregados para registradores antes disso. Isso nos permite dizer que não teremos uma sobreposição do estágio de execução.

Máquinas como o x86 podem utilizar operandos direto da memória e isso faz com que algumas salva-guardas precisem ser feitas no processo de pipeline, complicando mais esse processo.

# Hazards

## Hazards de dados

Um hazard é um problema que pode acontecer durante a paralelização de instruções, que consiste no impedimento da próxima instrução executar no próximo ciclo de relógio. Nesse caso, precisamos esperar que essa instrução possa ser executada, causando _stall_ ou pausa na do pipeline. Também dizemos que quando isso ocorre uma "bolha" é inserida no pipeline.

Por exemplo, caso eu tente executar as duas instruções abaixo:

```assembly
add $s0, $t0, $t1
sub $t2, $s0, $t3
```

Perceba que a segunda instrução utiliza como operador um resultado que foi adquirido na primeira instrução. Em um hardware sequencial monociclo, essa execução ocorreria sem problema algum. Porém numa situação de pipeline, eu sei que o valor resultante da operação `add` só será escrito no registrador `$s0` no estágio 5 (WB), portanto quando a operação `sub` tentar utilizar o valor de `$s0` em seu estágio 2, ele ainda não está pronto e a instruçao vai usar um valor qualquer que esteja no registrador previamente.

Quando uma instrução 2 depende de um dado que é produzido pela instrução 1, dizemos que isso é um dependência de dados. Quando essa dependência faz com que a pipeline tenha que ser atrasada, dizemos que isso é um hazard de dados. Todo hazard de dados vem de uma dependência de dados, mas nem toda dependência de dados gera um hazard.

![](https://imgur.com/x0TYavG.png)

### Soluções para hazards de dados

Uma das técnicas utilizadas para resolver o hazard de dados é o _forwarding_ ou _bypassing_, e ela se baseia no fato de que o resultado das operações está disponível logo após a execução da ULA no estágio EX, então o processador possui hardware específico adicional com a capacidade de realizar esse _forwarding_ entre uma instrução produtora e outra consumidora.

O caso abaixo mostra um _forwarding_ realizado entre duas instruções do tipo R, quando o caso é esse, nós podemos manter o fluxo do pipeline exatamente como estava antes, sem nenhum atraso.

![](https://imgur.com/PezkjBP.png)

Mas nesse outro caso, quando o _forwarding_ é realizado de uma instrução `lw` para uma instrução do tipo R, o meu dado só fica pronto após o estágio ME, então o _forwarding_ tem que ser um pouco mais na frente, criando um atraso.

![](https://imgur.com/rZ2XKCy.png)

E não tem como resolver isso? Bom, mais ou menos, existe outra técnica chamada _code schedulling_ que consiste em reordenar as instruções que estão causando atrasos na execução, tomando cuidado para não prejudicar dependências de dados, para eliminar os atrasos. O `gcc` pode fazer isso pra você se você passar a flag `-fschedule-insns`.

Pra exemplificar essa tećnica, vamos utilizar o seguinte código C, onde as variáveis estão alocadas em ordem alfabética a partir de um endereço que estará no registrador `$t0`.

```c
A = B + E;
C = B + F;
```

Que em assembly seria traduzido para algo como:

```assembly
lw $t1, 0($t0)
lw $t2, 4($t0)
add $t3, $t1, $t2
sw $t3, 12($t0)
lw $t4, 8($t0)
add $t5, $t1, $t4
sw $t5, 16($t0)
```

Criando um diagrama de pipeline, temos:

![](https://imgur.com/9HfliPm.png)

Percebemos que dois ciclos inteiros do meu processador foram atrasados por causa de dependências geradas entre dois pares de `lw` e `add`. E se nós separarmos essas dependências com uma instrução de "folga" cada? Podemos fazer isso antecipando a execução da linha `lw $t4, 8($t0)`.

![](https://imgur.com/aHUNFrA.png)

Que beleza, nesse nosso mundinho perfeito conseguimos remover completamente os atrasos, mas pode ser que nem sempre isso seja possível, pode ser que nenhuma instrução possa ser trocada de ordem e você não resolva nada ou pode ser que só algumas sejam resolvidas, tudo vai depender da situação específica.