#coloquei .data e .text
.data
v:
  .word 9
  .word 2
  .word 5
  .word 1
  .word 8
  .word 2
  .word 4
  .word 3
  .word 6
  .word 7
LC0: #Modifiquei a label tirando o %d
  .string "\t" 
  
.text
jal main
  
show: #Tirei os Argumentos
  addi sp,sp,-48
  sw ra,44(sp)
  sw s0,40(sp)
  addi s0,sp,48
  sw a0,-36(s0)
  sw a1,-40(s0)
  sw zero,-20(s0)
.L3:
  lw a4,-20(s0)
  lw a5,-40(s0)
  bge a4,a5,.L2
  lw a5,-20(s0)
  slli a5,a5,2
  lw a4,-36(s0)
  add a5,a4,a5
  lw a5,0(a5)
  mv a1,a5
  mv a0,a5
  li a7,1 #Troquei o call printf por syscall de print int para imprimir os numeros do vetor
  ecall
  la a0,LC0 #Coloquei o tab depois do printf e chamei o syscall de print string
  li a7,4
  ecall
  lw a5,-20(s0)
  addi a5,a5,1
  sw a5,-20(s0)
  j .L3
.L2:
  li a0,10
  li a7,11 #Troquei o call putchar por syscall de print char para imprimir o\n
  ecall
  nop
  lw ra,44(sp)
  lw s0,40(sp)
  addi sp,sp,48
  jr ra
swap: #Tirei os Argumentos
  addi sp,sp,-48
  sw s0,44(sp)
  addi s0,sp,48
  sw a0,-36(s0)
  sw a1,-40(s0)
  lw a5,-40(s0)
  slli a5,a5,2
  lw a4,-36(s0)
  add a5,a4,a5
  lw a5,0(a5)
  sw a5,-20(s0)
  lw a5,-40(s0)
  addi a5,a5,1
  slli a5,a5,2
  lw a4,-36(s0)
  add a4,a4,a5
  lw a5,-40(s0)
  slli a5,a5,2
  lw a3,-36(s0)
  add a5,a3,a5
  lw a4,0(a4)
  sw a4,0(a5)
  lw a5,-40(s0)
  addi a5,a5,1
  slli a5,a5,2
  lw a4,-36(s0)
  add a5,a4,a5
  lw a4,-20(s0)
  sw a4,0(a5)
  nop
  lw s0,44(sp)
  addi sp,sp,48
  jr ra
sort: #Tirei os Argumentos
  addi sp,sp,-48
  sw ra,44(sp)
  sw s0,40(sp)
  addi s0,sp,48
  sw a0,-36(s0)
  sw a1,-40(s0)
  sw zero,-20(s0)
.L9:
  lw a4,-20(s0)
  lw a5,-40(s0)
  bge a4,a5,.L10
  lw a5,-20(s0)
  addi a5,a5,-1
  sw a5,-24(s0)
.L8:
  lw a5,-24(s0)
  bltz a5,.L7
  lw a5,-24(s0)
  slli a5,a5,2
  lw a4,-36(s0)
  add a5,a4,a5
  lw a4,0(a5)
  lw a5,-24(s0)
  addi a5,a5,1
  slli a5,a5,2
  lw a3,-36(s0)
  add a5,a3,a5
  lw a5,0(a5)
  ble a4,a5,.L7
  lw a1,-24(s0)
  lw a0,-36(s0)
  call swap #Tirei os Argumentos
  lw a5,-24(s0)
  addi a5,a5,-1
  sw a5,-24(s0)
  j .L8
.L7:
  lw a5,-20(s0)
  addi a5,a5,1
  sw a5,-20(s0)
  j .L9
.L10:
  nop
  lw ra,44(sp)
  lw s0,40(sp)
  addi sp,sp,48
  jr ra
main: #Dei um jal na main
  addi sp,sp,-16
  sw ra,12(sp)
  sw s0,8(sp)
  addi s0,sp,16
  li a1,10
  lui a5,%hi(v)
  addi a0,a5,%lo(v)
  call show #Tirei os Argumentos
  li a1,10
  lui a5,%hi(v)
  addi a0,a5,%lo(v)
  call sort #Tirei os Argumentos
  li a1,10
  lui a5,%hi(v)
  addi a0,a5,%lo(v)
  call show #Tirei os Argumentos
  li a5,0
  mv a0,a5
  lw ra,12(sp)
  lw s0,8(sp)
  addi sp,sp,16
  jr ra
