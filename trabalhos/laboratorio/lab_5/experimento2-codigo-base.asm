.data
_v: .word 9,8,7,6,5,4,3,2,1,-1
_n: .word 10

.text
.globl main

main:
  la   $a0,_v  
  lw   $a1,_n 
  addi $s3, $zero, 2019
  jal sort             # MARCA 3
  addi $t1, $s3, 1     # MARCA 4
  li  $v0,10           # MARCA 5: syscall code = exit
  syscall
  
sort:
  addi $sp,$sp,-12 
  sw   $ra,8($sp) 
  sw   $s1,4($sp)  
  sw   $s0,0($sp)  


  move $s0,$zero   # MARCA 0: inicialização da variável i

# início do corpo do laço externo
for1tst:  

  nop # MARCA 1
  slt  $t0,$s0,$a1 
  beq  $t0,$zero,exit1  
  addi $s1,$s0,-1  

# inicio do corpo do laço interno
for2tst:
  slti $t0,$s1,0  
  bne  $t0,$zero,exit2 
  sll  $t1,$s1,2   
  add  $t2,$a0,$t1 
  lw   $t3,0($t2)
  lw   $t4,4($t2)
  slt  $t0,$t4,$t3
  beq  $t0,$zero,exit2

  move $a1, $s1
  nop # MARCA 2
  jal  swap 	
  addi $s1,$s1,-1
  j    for2tst
# fim do corpo do laço interno
exit2:
  addi $s0,$s0,1
  j    for1tst
# fim do corpo do laço externo
exit1:
  lw   $s0,0($sp)  
  lw   $s1,4($sp)
  lw   $ra,8($sp)
  addi $sp,$sp,12
  jr   $ra
# implementação da procedure swap
swap:
  sll  $t1,$a1,2   # reg $t1=k+4
  add  $t1,$a0,$t1 # reg $t1=v+(k*4)
  lw   $t0,0($t1)  # reg $t0 (temp)  =v[k]
  lw   $t2,4($t1)  # reg $t2 = v[k+1]
  sw   $t2,0($t1)  # v[k] = reg $t2
  sw   $t0,4($t1)  # v[k+1] = reg $t0 temp
  jr   $ra         # retorna para a rotina chamadora
  
