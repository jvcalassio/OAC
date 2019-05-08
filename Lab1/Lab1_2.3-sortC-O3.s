.data
.LANCHOR0: .word 9,2,5,1,8,2,4,3,6,7
.LC0: .string "\t"

.text
	jal main
	li a7,10
	ecall
show:
  blez a1,.L6
  addi sp,sp,-16
  sw s1,4(sp)
  slli s1,a1,2
  sw s0,8(sp)
  sw s2,0(sp)
  sw ra,12(sp)
  mv s0,a0
  add s1,a0,s1
  lui s2,%hi(.LC0)
.L3:
  lw a0,0(s0)
  lw a1,0(s0)
  li a7,1
  ecall # print numero
  
  addi a0,s2,%lo(.LC0)
  addi s0,s0,4
  li a7,4
  ecall # print \t
  bne s1,s0,.L3
  
  lw s0,8(sp)
  lw ra,12(sp)
  lw s1,4(sp)
  lw s2,0(sp)
  li a0,10
  addi sp,sp,16
  li a7,11
  ecall # print \n
.L6:
  li a0,10
  li a7,11 
  ecall # print \n
  ret
  
swap: # inutil, nao utilizado pelo codigo
  slli a1,a1,2
  addi a5,a1,4
  add a5,a0,a5
  lw a3,0(a5)
  add a0,a0,a1
  lw a4,0(a0)
  sw a3,0(a0)
  sw a4,0(a5)
  ret
sort:
  blez a1,.L11
  li a7,0
  addi t3,a1,-1
  li a6,-1
  mv a5,a7
  beq a7,t3,.L11
.L20:
  lw a4,0(a0)
  lw a1,4(a0)
  addi t1,a0,4
  mv a3,t1
  mv a2,a0
  bgt a4,a1,.L15
  j .L16
.L19:
  lw a4,-4(a2)
  addi a0,a0,-4
  addi a2,a2,-4
  addi a3,a3,-4
  ble a4,a1,.L16
.L15:
  sw a1,0(a0)
  sw a4,0(a3)
  addi a5,a5,-1
  bne a5,a6,.L19
.L16:
  addi a7,a7,1
  mv a0,t1
  mv a5,a7
  bne a7,t3,.L20
.L11:
  ret
main:
  addi sp,sp,-16
  sw s0,8(sp)
  lui s0,%hi(.LANCHOR0)
  addi a0,s0,%lo(.LANCHOR0)
  li a1,10
  sw ra,12(sp)
  call show
  addi a0,s0,%lo(.LANCHOR0)
  li a1,10
  call sort
  addi a0,s0,%lo(.LANCHOR0)
  li a1,10
  call show
  lw ra,12(sp)
  lw s0,8(sp)
  li a0,0
  addi sp,sp,16
  jr ra
