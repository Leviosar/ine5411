# 1.5 

Consider three different processors P1, P2, and P3 executing the same ISA.

| Processor | CPI | Frequency |
| --------- | --- | --------- |
| P1        | 1.5 | 3GHz      |
| P2        | 1.0 | 2.5GHz    |
| P3        | 2.2 | 4.0GHz    |

## 1.5.1

Which processor has the highest performance expressed in instructions per second?

**Resposta:**

Primeiro, vamos lembrar que para calcular instruções por segundo podemos chegar numa fórmula com:

```
Instruções / Segundo = Instruções / Ciclo × Ciclos / Segundo = 1 / CPI × f = f / CPI
```

Considerando que temos o CPI e a frequência dos 3 processadores, é trivial calcular o número de instruções por segundo (IPS).

```
IPS(P1) = 3×10⁹ / 1.5 = 2×10⁹
IPS(P2) = 2.5×10⁹ / 1.0 = 2.5×10⁹
IPS(P3) = 4.0×10⁹ / 2.2 = 1.8×10⁹ 
```

Sendo assim, o processador P2 possui o maior número de instruções executadas por segundo.

## 1.5.2

If the processors each execute a program in 10 seconds, find the number of cycles and the number of instructions.

**Resposta:**

Primeiro, podemos calcular o número de ciclos totais executados simplesmente multiplicando a frequência pelo tempo de execução (que foi dado como 10 no enunciado).

```
Ciclos(P1) = 10 × 3 × 10⁹ = 30 × 10⁹ 
Ciclos(P2) = 10 × 2.5 × 10⁹ = 25 × 10⁹
Ciclos(P3) = 10 × 4 × 10⁹ = 40 × 10⁹
```

Agora podemos obter o número de instruções dividindo o número de ciclos totais pelo CPI.

```
I = Ciclos / CPI

I(P1) = 30 × 10⁹ / 1.5 = 20 × 10⁹ 
I(P2) = 25 × 10⁹ / 1 = 25 × 10⁹
I(P3) = 40 × 10⁹ / 2.2 = 18.18 × 10⁹
```

## 1.5.3

We are trying to reduce the execution time by 30% but this leads to an increase of 20% in the CPI. What clock rate should we have to get this time reduction?

**Resposta:**

O enunciado nos diz que o tempo de execução foi reduzido em 30%, o que nos deixa com 7s de execução. Além disso, ele diz que o CPI dos processadores aumentou em 20%, dessa forma precisamos ajustar o CPI para:

```
CPI(P1) = 1.2 × 1.5 = 1.8
CPI(P1) = 1.2 × 1.0 = 1.2
CPI(P1) = 1.2 × 2.2 = 2.64
```

Agora, com os novos CPIs e o novo TEXEC precisamos calcular a frequência baseados em `TEXEC = I × CPI × (1 / f) ⇔ f = I × CPI / TEXEC`

```
P1 → f = 20 × 10⁹ × 1.8 / 7 = 5.14 × 10⁹ = 5.14 GHz
P2 → f = 25 × 10⁹ × 1.2 / 7 = 4.28 × 10⁹ = 4.26 GHz
P3 → f = 18.18 × 10⁹ × 2.64 / 7 = 6.85 × 10⁹ = 6.85 GHz
```

# 1.7

Compilers can have a profound impact on the performance of an application. Assume that for a program, compiler A results in a dynamic instruction count of 1.0E9 and has an execution time of 1.1s, while compiler B results in a dynamic instruction count of 1.2E9 and an execution time of 1.5 s.

| Compiler | Instructions | Execution time |
| -------- | ------------ | -------------- |
| A        | 1 × 10⁹      | 1.1s           |
| B        | 1.2 × 10⁹    | 1.5s           |

## 1.7.1

Find the average CPI for each program given that the processor has a clock cycle time of 1 ns.

**Resposta:**

Sabemos pelo enunciado que a frequência do processador é de 1 × 10⁹ (dado um período de 1 ns), também temos os dados de tempo de execução e número de instruções, utilizando a fórmula `TEXEC = I × CPI × (1 / f)` podemos isolar o CPI facilmente tendo `CPI = TEXEC / T × I`.

```
A → CPI = 1.1 / 1 × 10⁻⁹ × 1 × 10⁹ = 1.1
B → CPI = 1.5 / 1 × 10⁻⁹ × 1.2 × 10⁹ = 1.5 / 1.2 = 1.25
```

## 1.7.2

Assume the compiled programs run on two different processors. If the execution times on the two processors are the same, how much faster is the clock of the processor running compiler A’s code versus the clock of the processor running compiler B’s code?

**Resposta:**

Queremos encontrar uma relação entre as frequências de dois processadores que executam dois programas compilados de forma diferente no mesmo tempo. Podemos então desprezar o tempo e trabalhar apenas com I e CPI (que já temos calculados). A relação deve considerar o "pior" compilador como a parte de cima da fração, então temos que:

```
F(B) / F(A) = [I(B) × CPI(B)] / [I(A) × CPI(A)]
F(B) / F(A) = [1.2 × 10⁹ × 1.25] / [1 × 10⁹ × 1.1]
F(B) / F(A) = [1.5 × 10⁹] / [1.1 × 10⁹]
F(B) / F(A) = 1.5 / 1.1 = 1.3636_
```

## 1.7.3

A new compiler is developed that uses only 6.0E8 instructions and has an average CPI of 1.1. What is the speedup of using this new compiler versus using
compiler A or B on the original processor?

**Resposta:**

Primeiro, precisamos pegar o tempo de execução do código gerado por esse novo compilador, para isso usamos `TEXEC = I × CPI × T`

```
TEXEC = 6 × 10⁸ × 1.1 × 1 × 10⁻⁹
TEXEC = 6.6 × 10⁻¹ = 0.66s
```

Com o tempo calculado fazemos `Tempo antigo / Tempo novo` para encontra o speedup

```
Speedup(A) = 1.1 / 0.66 = 1.66
Speedup(B) = 1.5 / 0.66 = 2.27_
```

# 1.8 