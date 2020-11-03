.data
_save: 9999,8,6,6,6,6,6,6,6,6
_k: .word 6 
_error: .asciiz "Index Out of Bounds Exception"	    
.text
.globl main

main: 
    # inicializa��o
    la $s6, _save
    lw $s5, _k
    addi $s3, $zero, 0
    lw $t2, 4($s6)

Loop: 
    # verifica��o de limite do arranjo
    sltu $t0, $s3, $t2 # i < x
    beq $t0, $zero, IndexOutOfBounds

    # corpo do la�o
    sll $t1, $s3, 2    
    add $t1, $t1, $s6 
    lw $t0, 8($t1)
    bne $t0, $s5, Exit    
    addi $s3, $s3, 1      
    j Loop

Exit: # rotina para imprimir inteiro no console
    addi $v0, $zero, 1
    add $a0, $zero, $s3
    syscall
    j End

IndexOutOfBounds: # rotina para imprimir mensagem de erro no console
    addi $v0, $zero, 4
    la $a0, _error
    syscall
    End:   
