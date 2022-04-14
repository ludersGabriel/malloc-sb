.section .data

# variaveis globais
topoInicialHeap: .quad 0
topoHeap: .quad 0
str1: .string "Init heap space\n"
strLabels: .string "oc, qtd: %ld, %ld\n" 
str2: .string "topoInit, actualTopo: %ld, %ld\n"
strMANAGER: .string "#"
strUNUSED: .string "-"
strUSED: .string "+"

#constantes
.equ MEM_POOL, 26
.equ UNUSED, 0
.equ USED, 1

.section .text
.globl iniciaAlocador, printTopo, finalizaAlocador, topoInicialHeap, imprimeMapa

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

  # sets the first mem pool
  addq $MEM_POOL, %rax
  movq %rax, %rdi
  movq $12, %rax
  syscall
  movq %rax, topoHeap

  # write initial labels
  movq topoInicialHeap, %rax
  movq $UNUSED, (%rax)
  movq $MEM_POOL, 8(%rax)

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

imprimeMapa:
  pushq %rbp
  movq %rsp, %rbp 

  movq $0, %rbx

movq topoInicialHeap, %rax
forImprime:
  cmpq topoHeap, %rax
  jge endForImprime

  forManager:
    cmpq $16, %rbx
    jge endForManager

    pushq %rax
    movq $0, %rax
    movq $strMANAGER, %rdi
    call printf
    popq %rax

    addq $1, %rbx
    jmp forManager
  endForManager:

  movq $UNUSED, %rbx
  cmpq (%rax), %rbx
  je elseImprime
  movq $strUSED, %rdx
  jmp endIfImprime
  elseImprime:
    movq $strUNUSED, %rdx
  endIfImprime:

  movq 8(%rax), %rcx
  movq $0, %rbx
  forImprimeData:
    cmpq %rcx, %rbx
    jge endForImprime

    pushq %rcx
    pushq %rax
    pushq %rdx

    movq $0, %rax
    movq %rdx, %rdi
    call printf
    
    popq %rdx
    popq %rax
    popq %rcx

    addq $1, %rbx
    jmp forImprimeData
  endForImprimeData:

  movq 8(%rax), %rbx
  addq %rbx, %rax
  addq $16, %rax
  jmp forImprime
endForImprime:
  popq %rbp
  ret

printTopo: 
  push %rbp
  movq %rsp, %rbp
  
  movq topoInicialHeap, %rbp
  
  movq $str2, %rdi
  movq topoInicialHeap, %rsi
  movq topoHeap, %rdx
  call printf

  movq $strLabels, %rdi
  movq (%rbp), %rsi
  movq 8(%rbp), %rdx
  call printf

  popq %rbp
  ret
