# Pipelines

O pipeline é uma técnica de paralelismo em hardware, baseada num fluxo de linha de montagem, onde existem N etapas independentes e sequenciais. Quando utilizamos essa técnica em uma CPU, separamos as etapas como partes de uma instrução, no MIPS são utilizadas 5 etapas:

1. Instruction fetch (IF)
2. Instruction decode (ID)
3. Execução: operação/cálculo de endereço (EX)
4. Acesso ao operando em memória (ME)
5. Escrita do resultado da operação no registrador (MB)

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