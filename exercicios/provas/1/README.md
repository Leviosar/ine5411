# Prova 1

## Questão 4

Os processadores X e Y são ambos compatíveis com ARMv8. Suponha que um mesmo programa escrito na linguagem C foi compilado para executar em X e Y, usando o mesmo compilador e exatamente as mesmas opções (flags) de compilação. Sabe-se que as frequências de X e Y são, respectivamente, 1GHz e 2GHz. Nestas condições, qual(is) das seguintes afirmações é (são) verdadeira(s)?

Escolha uma ou mais:

- [x] O número de instruções executadas é o mesmo em X e Y.
> Como os dos processadores compartilham a mesma ISA, e os compiladores e otimizações utilizados foram os mesmos, temos certeza de que as mesmas instruções serão executadas
- [ ] O número de instruções executadas em Y é 2 vezes maior que em X.
- [ ] Nada se pode afirmar sobre o número de instruções executadas.
- [ ] O número de instruções por segundo é o mesmo em X e Y.
- [ ] O número de instruções por segundo é 2 vezes maior em Y do que em X.
- [x] Nada se pode afirmar sobre o número de instruções por segundo.
> Apesar da ISA ser a mesma, podem existir diferenças na implementação do hardware, portanto não é possível dizer nada sobre a quantidade de instruções por segundo.
- [ ] O número de ciclos por segundo é o mesmo em X e Y.
- [x] O número de ciclos por segundo é 2 vezes maior em Y do que em X.
> O número de ciclos por segundo depende exclusivamente da frequência do processador, como Y possui 2 vezes a frequência de X, também terá duas vezes o número de ciclos por segundo.
- [ ] Nada se pode afirmar sobre o número de ciclos por segundo.
- [ ] O número de ciclos por instrução é o mesmo em X e Y.
- [ ] O número de ciclos por instrução é 2 vezes menor em Y.
- [x] Nada se pode afirmar sobre o número de ciclos por instrução.
> Assim como não podemos afirmar nada sobre o número de instruções por segundo devido a diferenças entre os hardwares, não podemos dizer nada sobre o número de ciclos por instrução, já que por exemplo um load pode levar mais ciclos em um processador do que no outro. 

## Questão 5

A instrução `beq $s1, $s2, label` reside no endereço `0x 0FFC 0008`. Para o MIPS32, qual o endereço-efetivo mínimo atingível por esta instrução?

### Resolução

Considerando um MIPS32, o endereço mínimo atingível por uma instrução BEQ é o menor número negativo representável por 16 bits com complemento de 2. Nesse caso, 0x1FFFC.

`0x 0FFC 0008 - 0x1FFFC = 0x 0FFA 000C`