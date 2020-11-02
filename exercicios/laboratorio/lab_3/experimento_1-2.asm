.data
_save: .word 6,6,6,6,6,6,6
_k: .word 6             
.text
.globl main
main: 

la $s6, _save # puxar o valor de _save pro registrador $t6
lw $s5, _k # puxa o valor de k pro registrador $t5
addi $s3, $zero, 0 # adiciona o valor 0 ao registrador $s3

Loop:
sll $t1, $s3, 2 # multiplica por 4 o valor de $s3 e guarda em $t1
add $t1, $t1, $s6  # adiciona $s6 (a base de save) ao valor atual de $t1
lw $t0, 0($t1)  # carrega no registrador $t0 o valor de memória de $t1, ou save[i]
bne $t0, $s5, Exit # verifica se k = save[i]. caso seja diferença envia ao Exit
addi $s3, $s3, 1 # adiciona 1 ao contador $s3
j Loop
                
Exit:
addi $v0, $zero, 1
add $a0, $zero, $s3
syscall     
