.data
.LANCHOR0: .word 9,2,5,1,8,2,4,3,6,7
.LC0: .string "\t"

.text
	jal main # chama main
	li a7,10
	ecall # finaliza execucao
	
show:
  addi sp,sp,-32
  sw s0,24(sp)
  sw s1,20(sp)
  sw s2,16(sp)
  sw s3,12(sp)
  sw ra,28(sp)
  mv s3,a1
  mv s0,a0
  li s1,0
  lui s2,%hi(.LC0)
.L3:
  bge s1,s3,.L2
  lw a0,0(s0)
  li a7,1
  ecall # print numero
  
  addi a0,s2,%lo(.LC0)
  li a7,4
  ecall # print \t
  
  addi s1,s1,1
  addi s0,s0,4
  j .L3
.L2:
  lw s0,24(sp)
  lw ra,28(sp)
  lw s1,20(sp)
  lw s2,16(sp)
  lw s3,12(sp)
  li a0,10
  addi sp,sp,32
  li a7,11
  ecall # print \n
  ret
swap:
  slli a1,a1,2
  add a5,a0,a1
  addi a1,a1,4
  add a0,a0,a1
  lw a3,0(a0)
  lw a4,0(a5)
  sw a3,0(a5)
  sw a4,0(a0)
  ret
sort:
  addi sp,sp,-32
  sw s1,20(sp)
  sw s3,12(sp)
  sw s4,8(sp)
  sw s5,4(sp)
  sw ra,28(sp)
  sw s0,24(sp)
  sw s2,16(sp)
  mv s3,a0
  mv s4,a1
  li s1,0
  li s5,-1
.L10:
  bge s1,s4,.L6
  slli s0,s1,2
  addi s2,s1,-1
  add s0,s3,s0
.L9:
  beq s2,s5,.L8
  lw a4,-4(s0)
  addi s0,s0,-4
  lw a5,4(s0)
  ble a4,a5,.L8
  mv a1,s2
  mv a0,s3
  call swap
  addi s2,s2,-1
  j .L9
.L8:
  addi s1,s1,1
  j .L10
.L6:
  lw ra,28(sp)
  lw s0,24(sp)
  lw s1,20(sp)
  lw s2,16(sp)
  lw s3,12(sp)
  lw s4,8(sp)
  lw s5,4(sp)
  addi sp,sp,32
  jr ra
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
