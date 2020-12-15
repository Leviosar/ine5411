# Prova 2

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