# Desempenho: Benchmarks

Continuando ainda na ideia de medir o desempenho de processadores e programas, vamos ver algumas métricas utilizadas pelo mercado.

## SPEC CPU

O SPEC CPU Ratio é uma medida que utiliza um conjunto de programas pré definidos, executando eles na máquina que se deseja medir o desempenho e comparando ao desempenho de uma máquina base, no caso o `SUN UltraSparc@296MHz`. Dessa forma, ele gera uma razão do tipo:

```
SPEC Ratio = Tempo(Sun UltraSparc@296MHz) / Tempo(CPU)
```

No caso do SPEC, ele usa 12 programas de matemática discreta que utilizam dados inteiros, e 17 programas que utilizam ponto flutuante.

## SPEC POWER

Com o advento de parques de computadores em massa, os armazéns de cloud, se fez necessário medirmos a eficiência energética do sistema, em uma métrica de `Operações/Joule`, a métrica `SPEC POWER` tem essa finalidade.

O SPEC POWER compara o consumo de energia de servidores para diferentes níveis de carga, partindo de 0% de carga até 100% de carga, pulando de 10 em 10%. Medindo o desempenho em `Operações/s` dividido pela potência em `Watts (Joules/s)`, se você fez física no ensino médio sabe que dividindo valores nessas medidas vamos obter um resultado em `Operações/Joule` como queriamos no começo.

## Melhorias no desempenho

Dada uma ISA, como podemos melhorar o desempenho de programar?

1. Maior frequência de relógio
    - Melhores tecnologias de fabricação
    - Tem um limite pra isso antes de fritar o PC

2. Menor número de instruções
    - Escolha de um algoritmo melhor, opções de compilação

3. Menor CPI
    - Escolha de uma organização melhor (pipeline, cores, cache)
    - Paralelização 