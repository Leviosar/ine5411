# if (j == j) f = g + h; else f = g - h;

.text
.globl main
main:
  bne		$s3, $s4, Else	# if i != $j then target
  add		$s0, $s1, $s2	# f = g + h
  j Exit
Else: 
  sub		$s0, $s1, $s2	# f = g - h
Exit:

# while (save[i] == k):
# i += 1;
# $s3 = i
# $s5 = k
# $s6 = base of save

Loop: 
  sll       $t1, $s3, 2    # $t1 = i * 4
  add		$t1, $t1, $s6  # $t1 = address of save[i]
  lw		$t0, 0($t1)	   # $t0 = value of save[i] 
  bne		$t0, $s5, Exit # if save[i] != k, go to exit
  addi	    $s3, $s3, 1    # i += 1
  j Loop
Exit: