.section .text
.globl print
print:
  pushq %rbp
  movq %rsp, %rbp
  
  movq $0, %rax
  call printf
  
  popq %rbp
  ret
