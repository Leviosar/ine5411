# Prova 2

## Questão 3

Lembre que o MIPS usa um pipeline de 5 estáagios (IF, ID, EX, ME, WB), que permite a escrita e a leitura de registradores em semiciclos distintos de um mesmo ciclo. Suponha que o pipeline original seja assim modifcado:

- O estágio ME foi particionado em dois estáagios ME1 e ME2, separados por uma barreira temporal (o primeiro acomoda o decodificador de endereços e o segundo as células de memória). Isto permite que o endereço de um dado seja decodificado em paralelo com o acesso (em memória) ao dado cujo endereço foi decodificado no ciclo anterior. 

Sabe-se que o datapath é capaz de detectar hazards de dados para provocar pausas (quando necessário), mas não possui suporte a forwarding. Cada código da tabela abaixo seria executado (individualmente) no novo pipeline.

| A             | B             | C             |
| ------------- | ------------- | ------------- |
| lw $s1,8($s0) | lw $s1,8($s0) | sw $s1,8($s0) |
| sw $s2,8($s1) | sw $s1,8($s2) | lw $s2,8($s0) |

Nestas condições, A requer X ciclos, B requer Y ciclos e C requer Z ciclos.

> Vamos calcular a quantidade de ciclos um por um, usando diagramas de pipeline.

### Código A

| Instrução         | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    | 9    | 10   |
| ----------------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| **lw $s1,8($s0)** | `IF` | `ID` | `EX` | `M1` | `M2` | `WB` |      |      |      |      |
| **sw $s2,8($s1)** |      |      |      |      | `IF` | `ID` | `EX` | `M1` | `M2` | `WB` |

O valor de $s1 é escrito pela primeira instrução apenas no estágio WB, e precisamos dele disponível no estágio ID da segunda instrução. Como o enunciado diz que a escrita e leitura do banco de registradores são feitas em semiciclos diferentes, podemos paralelizar os estágios ID e WB dessas duas instruções. Assim, temos o diagrama acima e chegamos no valor de 10 ciclos. 

### Código B

| Instrução         | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    | 9    | 10   |
| ----------------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| **lw $s1,8($s0)** | `IF` | `ID` | `EX` | `M1` | `M2` | `WB` |      |      |      |      |
| **sw $s1,8($s2)** |      |      |      |      | `IF` | `ID` | `EX` | `M1` | `M2` | `WB` |

Aqui ainda precisamos de `$s1` setado com o valor correto no estágio `ID` da segunda instrução, pois a leitura dos registradores acontece ali sendo eles de fonte ou destino, então o diagrama não é alterado e continuamos tendo 10 ciclos.

### Código C

| Instrução         | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8   | 9   | 10  |
| ----------------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | --- | --- | --- |
| **sw $s1,8($s0)** | `IF` | `ID` | `EX` | `M1` | `M2` | `WB` |      |     |     |     |
| **lw $s2,8($s0)** |      | `IF` | `ID` | `EX` | `M1` | `M2` | `WB` |     |     |     |

## Questão 4

Lembre que o MIPS usa um pipeline de 5 estágios (IF, ID, EX, ME, WB), que permite a escrita e a leitura de registradores em semiciclos distintos de um mesmo ciclo. Suponha que o pipeline original seja assim modificado:

- O estágio IF foi particionado em dois estágios IF1 e IF2, separados por uma barreira temporal (o primeiro acomoda o decodificar de endereço e o segundo as células de memória). Isto permite que o endereço de uma instrução seja decodificado em paralelo com o acesso (em memória) à instrução cujo endereço foi decodificado no ciclo anterior.

Sabe-se que o hardware faz previsão estática sob a hipótese de desvio não tomado e é capaz de anular instruções que tenham sido buscadas indevidamente. Sabe-se que o endereço-alvo de um desvio condicional está disponível na saída do estágio ID (ao final do ciclo). Suponha que o código abaixo seja executado em duas variantes diferentes de datapath:

Variante A: Resultado do teste de condição disponível na saída da ALU (ao final do ciclo).
Variante B: Resultado do teste de condição disponível na saída do estágio ID (ao final do ciclo).

```assembly
    beq $s0,$s1,L
    add $s2,$s3,$s4
    add $t0,$t1,$t2
    add $t3,$t4,$t5
    add $t6,$t7,$t8
L: 
    sw $s5,8($s6)
```

Nestas condições, supondo o cenário em que a previsão resulte incorreta, o código abaixo requer [10] ciclos na variante A e [9] ciclos na variante B.

### Variante A

Estágios marcados com * são anulados pelo processador.

| Instrução             | 1   | 2   | 3   | 4   | 5    | 6   | 7   | 8   | 9   | 10  |
| --------------------- | --- | --- | --- | --- | ---- | --- | --- | --- | --- | --- |
| **beq $s0, $s1, L**   | IF1 | IF2 | ID  | EX  | ME   | WB  |     |     |     |     |
| **add $s2, $s3, $s4** |     | IF1 | IF2 | ID  | EX*  | ME* | WB* |     |     |     |
| **add $t0, $t1, $t2** |     |     | IF1 | IF2 | ID*  | EX* | ME* | WB* |     |     |
| **add $t3, $t4, $t5** |     |     |     | IF1 | IF2* | ID* | EX* | ME* | WB* |     |
| **sw  $s5, 8($s6)**   |     |     |     |     | IF1  | IF2 | ID  | EX  | ME  | WB  |

### Variante B

Estágios marcados com * são anulados pelo processador.

| Instrução             | 1   | 2   | 3   | 4    | 5   | 6   | 7   | 8   | 9   | 10  |
| --------------------- | --- | --- | --- | ---- | --- | --- | --- | --- | --- | --- |
| **beq $s0, $s1, L**   | IF1 | IF2 | ID  | EX   | ME  | WB  |     |     |     |     |
| **add $s2, $s3, $s4** |     | IF1 | IF2 | ID*  | EX* | ME* | WB* |     |     |     |
| **add $t0, $t1, $t2** |     |     | IF1 | IF2* | ID* | EX* | ME* | WB* |     |     |
| **sw  $s5, 8($s6)**   |     |     |     | IF1  | IF2 | ID  | EX  | ME  | WB  |     |

## Questão 5

Para um mesmo programa, dois compiladores distintos, C1 e C2, produziram arquivos executáveis diferentes, X1 e X2, respectivamente, para a arquitetura ARMv7. Pretende-se avaliar o desempenho desse programa – quando executado com exatamente os mesmos dados de entrada – em dois chips distintos e sob diferentes frequências de operação, conforme a tabela abaixo.

![](https://imgur.com/32TyRYa.png)

Mediram-se o tempo de execução e o número de instruções em apenas um dos quatro cenários e os resultados estão na tabela abaixo. A partir destes resultados experimentais, quer-se estimar o que ocorrerá nos demais cenários.
 
![](https://imgur.com/b20M13y.png)

Nestas condições, qual (is) das seguintes afirmações é (são) verdadeira(s)?

Escolha uma ou mais:
- [ ] Para o A8 a 0,6 GHz, o tempo de execução de X1 será 10/6 s.
- [x] Para o A8 a 0,6 GHz, nada se pode afirmar sobre o tempo de execução de X1.
> O tempo de execução foi medido apenas para o processador A15, e apesar dos dois compartilharem a mesma ISA, podem existir diferenças de implementação no hardware, portanto não podemos prever o comportamento do tempo de execução para o processador A8
- [ ] Para o A8 a 0,6 GHz, o tempo de execução de X2 será 2,5 s.
- [x] Para o A8 a 0,6 GHz, nada se pode afirmar sobre o tempo de execução de X2.
> O tempo de execução foi medido apenas para o processador A15, e apesar dos dois compartilharem a mesma ISA, podem existir diferenças de implementação no hardware, portanto não podemos prever o comportamento do tempo de execução para o processador A8
- [ ] Para o A8 a 1 GHz, o tempo de execução de X1 será 1 s.
- [x] Para o A8 a 1 GHz, nada se pode afirmar sobre o tempo de execução de X1.
> O tempo de execução foi medido apenas para o processador A15, e apesar dos dois compartilharem a mesma ISA, podem existir diferenças de implementação no hardware, portanto não podemos prever o comportamento do tempo de execução para o processador A8
- [ ] Para o A8 a 1 GHz, o tempo de execução de X2 será 1,5 s.
- [x] Para o A8 a 1 GHz, nada se pode afirmar sobre o tempo de execução de X2.
> O tempo de execução foi medido apenas para o processador A15, e apesar dos dois compartilharem a mesma ISA, podem existir diferenças de implementação no hardware, portanto não podemos prever o comportamento do tempo de execução para o processador A8
- [x] Para o A15 a 1,5 GHz, o tempo de execução de X1 será 2/3 s.
> Neste caso, o processador A15 é exatamente o mesmo, seja rodando a 1,5GHz ou 2Ghz, a única diferença será a frequência de relógio. Ao se realizar os cálculos chegamos a esse resultado de 0.66s de execução
- [ ] Para o A15 a 1,5 GHz, nada se pode afirmar sobre o tempo de execução de X1.
- [ ] Para o A15 a 1,5 GHz, o tempo de execução de X2 será 0,8 s.
> Neste caso, o processador A15 é exatamente o mesmo, seja rodando a 1,5GHz ou 2Ghz, a única diferença será a frequência de relógio. Mas, os cálculos não bem com o tempo de 0.8s da alternativa
- [ ] Para o A15 a 1,5 GHz, nada se pode afirmar sobre o tempo de execução de X2.

Pra fazer os cálculos dessa questão, você pode usar a noção de `texec = (I * CPI) / f`, como o tempo todo você estará comparando um processador com ele mesmo rodando em outra frequência, pode omitir o termo `CPI`, restando `texec = I / f`.

Exemplo: processador A15, frequência de 1,5 GHz, programa X1.

```
texec = 10⁹ / (1,5 * 10⁹)
texec = 1 / 1,5 = 0.666
```


## Questão 8

Um programa paralelo executa em 250 segundos em um único core. Sabe-se que 10% é a percentagem do tempo gasto executando instruções que estão encadeadas por dependências de dados. Quer-se aumentar o desempenho do programa através do aumento do número de cores, sendo que cada um deles é idêntico ao core original. Em um processador com 90 cores, qual será o tempo de execução do programa em segundos?

### Resolução

Para resolver essa questão usamos a lei de Ahmdal, a peça chave é entender que os 10% de instruções encadeadas por dependências de dados NÃO podem ser paralelizados, então eles são a parte sequencial do programa. Abaixo, segue a fórmula da lei de Ahmdal

![](https://imgur.com/tIDs05S.png)

```
tempo(90) = tempo(1) * (0.1 + ((1 - 0.1) / 90) )
tempo(90) = 250s * (0.1 + 0.01)
tempo(90) = 250 * 0.11 = 27.5s
```