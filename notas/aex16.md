# Hazards estruturais

Acontecem quando o hardware em estudo não suporta duas instruções de certo tipo simultâneamente, por falta de recursos ou por algo que não foi pensado durante o planejamento. É muito dificil a ocorrência de um hazard estrutural em instruções simples, mas podem começar a acontecer em instruções de ponto flutuante.

### Exemplos

1. Acesso de memória

Voltando no nosso pipeline anterior, caso os estágios ME e IF se sobrepossem em um MIPS de memória unificada (memória de dados e instruções em um mesmo bloco), duas instruções tentariam acessar o barramento de memória que permite apenas um acesso por vez, gerando um hazard estrutural.

No caso do MIPS, as implementações atuais já utilizam uma cache separada para dados e outra para instruções então esse hazard não é possível.

2. Acesso do banco de registradores

Outros dois estágios que poderiam nos causar problema são o ID e WB, já que ambos acessam o banco de registradores, o primeiro para ler e o segundo para escrever. Supondo que duas instruções estejam executando no pipeline, caso uma tente executar ID e a outra WB no mesmo ciclo, teriamos um hazard estrutural

Isso também é resolvido nas implementações do MIPS, fazendo a escrita no primeiro semi-ciclo e a leitura no segundo semi-ciclo.

# Hazards de controle

Esse tipo de hazards está relacionado a desvios condicionais e seus valores não estarem disponível em tempo de execução. Instruções de desvio como `beq` e `bne` precisam de um valor para a comparação, geralmente implementado com coisas como `slt`. Se o resultado da instrução produtora ainda não estiver disponível, temos um hazard de controle.

Esse problema tem 3 soluções:

1. Pausa o pipeline até que o resultado do teste esteja disponível
    - _Stall on branch_
2. Previsão do resultado do teste
    - _Branch prediction_
3. Desvios com retardo
    - _Delayed branch_

## _Stall on branch_

Nesse caso, vamos esperar o valor estar disponível para introduzir novas instruções no pipeline, é uma solução simplória e com grande impacto no desempenho do programa. Pra observar melhor esse impacto podemos usar um caso de exemplo. Suponha que no nosso hardware, o valor do teste é resolvido no segundo estágio de pipeline do MIPS, e olhe o seguinte código assembly:

```assembly
add $s0, $s1, $s2
beq $t0, $t1, L

L:
  or $s4, $s5, $s6
```

Desenhando um diagrama podemos perceber que a instrução que está na label L só vai começar a executar ao final do estágio 2 da instrução `beq`. Isso acaba atrasando todo o programa em um ciclo. Com centenas de desvios possíveis num programa, nosso desempenho se deteriora muito.

![](https://imgur.com/XSg6lWo.png)

## _Branch prediction_

Nesse caso, escolhemos uma regra ou um decisor que irá definir se iremos ou não fazer o desvio antes mesmo de termos o resultado da comparação, seguindo essa regra ela continua executando as próximas instruções até que o desvio fique pronto. Caso a hipótese de previsão se confirme, tudo certo e o código continua rodando de boa.

A forma mais simples de se fazer uma previsão, é de forma estática e negando o desvio, ou seja, diremos sempre que desvios NÃO são tomados, até que se prove o contrário. Essa forma certamente não é a mais eficiente, mas pra efeitos didáticos vamos exemplificar _branch prediction_ com ela.

Suponha novamente que nosso teste tem um resultado conhecido no segundo estágio, junto com o assembly a seguir:

```assembly
add $s0, $s1, $s2
beq $t0, $t1, L
lw $t2, $t3, 300($s3)

...

L: 
  or $s4, $s5, $s6
```

Se utilizarmos nossa hipótese de que desvios nunca desviam e acertarmos na nossa previsão (leia chute) durante o tempo de execução, não teremos penalidade, e o diagrama de execução do pipeline ficará como na imagem abaixo:

![](https://imgur.com/JapD4fb.png)

Mas caso nosso chute super bem embasado não se mostre verdadeiro, teremos que anular o efeito da nossa instrução que carregamos de maneira equivocada, além de buscar a nova instrução agora que temos o valor do teste. O diagrama ficaria como na imagem abaixo:

![](https://imgur.com/hMEb6vw.png)

Note que só tivemos essa penalidade nos casos onde não acertamos as previsões, esse caso já é consideravelmente melhor do que simplesmente atrasar todos os desvios, mas como veremos no futuro ainda podemos melhorar isso com previsores dinâmicos. Além disso, para implementarmos um previsor de branchs mesmo que estático, precisamos garantir que o hardware tem a capacidade de anular a instrução carregada de forma equivocada.

### Previsão dinâmica

Apesar de previsores estáticos serem melhores do que previsor nenhum, ainda temos algum espaço pra melhorar aqui, uma abordagem para esse problema é criar uma estrutura capaz de analisar o resultado de desvios passados e tentar modificar a previsão do programa conforme essa análise. Chamamos isso de previsão dinâmica.

#### _Branch history table_

Uma forma de implementar essa previsão dinânmica é com base em uma _branch history table_, uma estrutura de dados que contém 1 bit para sinalizar desvios tomados e não tomados, endereçada a partir dos bits menos significativos do PC. 

> Por que não utilizar todos os bits do PC para endereçar? Em um PC com 32 bits isso seriam 2^32 endereços, ou 4 GB de memória, algo inconcebível para estar DENTRO do processador.

Começamos com uma hipótese X, ao desviar, caso nossa hipótese de desvio se confirme nós salvamos o bit e segue o jogo. Caso a hipótese esteja equivocada nós invertemos o bit de rearmazenamos ele na tabela, além trocar nossa hipótese para -X no próximo desvio.

Em casos como o seguinte, nossa previsão vai nos salvar muuuuito tempo:

```c
int i = 0;

while(i < 400) {
  printf("%d", i);
}
```

Como o mesmo laço vai tomar 399 caminhos iguais antes de finalmente tomar um caminho diferente, teremos essa otimização para pelo menos 398 iterações. Mas e em um caso alternado?

```c
for(int i = 0; i < 400; i++) {
  if (i % 2 == 0) {
    printf("Par");
  } else {
    printf("Impar");
  }
}
```

Perceba que no caso acima, além do desvio presente na estrutura do laço, também temos um outro desvio interno que irá ser tomado sempre que um contador for ímpar (o que vai acontecer a cada 2 iterações do laço). Como nosso plano era trocar sempre que tivesse errado, vamos errar todas as vezes. Então, existem casos muito ruins para o nosso previsor.

A gente ainda pode dar uma alterada pra melhorar isso, aumentando a tolerância a erros do nosso previsor. Nesse caso, vamos trocar apenas DUAS previsões incorretas. Se você fizer os mesmos exemplos ali de cima vai perceber que melhoramos pra aqueles casos, mas se pensar mais um pouquinho vai achar casos que continuam ruins pro nosso previsor. Quer dizer então que nada dá certo? Que a vida é um erro? Não(sim)! 

Obviamente como esse método se baseia em uma heurística, ele não é perfeito, mas é uma implementação simples de se fazer e relativamente barata. Previsores de desvios são uma grande área de pesquisa da indústria, surgem novos métodos e implementações todo ano e com certeza existem vários mais complexos que o _BHT_.

A eficiência do BHT se mostra melhor em pipelines longos, com mais de 10 estágios. Como no MIPS estamos estudando um pipelinezinho mixuruca com 5 estágios podemos tomar previsões estáticas de desvio não-tomado em grandes penalidades para a performance do processador.

# A estrutura de um _datapath_ com suporte a pipeline

Uma das implementações de _datapath_ para um MIPS 32 que utiliza pipelines é bem parecida com a nossa implementação de MIPS 32 multi/monociclo feita na disciplina de Sistemas Digitais. A diferença principal é a utilização de registradores de sincronização para delimitar cada estágio do pipeline. Esses registradores não são acessíveis para o programador e nem possuem um nome definido no manual, mas são chamados de IF/ID, ID/EX, EX/MEM e MEM/WB pelos autores do livro texto da discplina.

![](https://imgur.com/AwePjbp.png)