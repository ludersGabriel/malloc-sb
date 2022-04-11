.section .data
  str1: .string "Printando qualquer coisa\n"
.section .text
.globl print
print:
  movq $0, %rax
  movq $str1, %rdi
  call printf
