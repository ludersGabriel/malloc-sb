.section .data
topoInicialHeap: .quad 0
str1: .string "Init heap space\n"
str2: .string "topo: %ld\n"
.section .text
.globl iniciaAlocador, printTopo, finalizaAlocador, topoInicialHeap
iniciaAlocador: 
  pushq %rbp
  movq %rsp, %rbp

  movq $0, %rax
  movq $str1, %rdi
  call printf

  movq $0, %rdi
  movq $12, %rax
  syscall
  movq %rax, topoInicialHeap

  popq %rbp
  ret

finalizaAlocador:
  pushq %rbp
  movq %rsp, %rbp

  movq topoInicialHeap, %rdi
  movq $12, %rax
  syscall

  popq %rbp
  ret

printTopo: 
  push %rbp
  movq %rsp, %rbp

  movq $str2, %rdi
  movq topoInicialHeap, %rsi
  call printf

  popq %rbp
  ret
