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
strENTER: .string "\n"

#constantes
.equ MEM_POOL, 100
.equ UNUSED, 0
.equ USED, 1

.section .text
.globl iniciaAlocador, printTopo, finalizaAlocador, topoInicialHeap, imprimeMapa, alocaMem

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
  movq %rax, %rdi
  addq $MEM_POOL, %rdi
  addq $16, %rdi
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

  movq topoInicialHeap, %rax
  forImprime:
    cmpq topoHeap, %rax
    jge endForImprime

    movq $0, %rbx
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
      jge endForImprimeData

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

    pushq %rcx
    pushq %rax
    pushq %rdx

    movq $strENTER, %rdi
    movq $0, %rax
    call printf

    popq %rdx
    popq %rax
    popq %rcx

    movq 8(%rax), %rbx
    addq %rbx, %rax
    addq $16, %rax
    jmp forImprime
  endForImprime:
    popq %rbp
    ret

alocaMem:
  pushq %rbp
  movq %rsp, %rbp

  movq $0, %r10 # what aloca returns

  movq topoInicialHeap, %rax
  movq %rdi, %rdx # in %rdi we have N
  addq $16, %rdx  # in %rdx we have N + 16
  forMem:
    cmpq topoHeap, %rax
    jge endForMem

    movq $UNUSED, %rbx
    cmpq (%rax), %rbx
    jne endIfUsed
    
    movq 8(%rax), %rbx # in %rbx, we have y
    cmpq %rbx, %rdx # N + 16 < Y
    jge endIf16
      movq $USED, %r9
      movq %r9, (%rax)
      movq %rdi, 8(%rax)

      movq %rax, %r10
      addq $16, %r10

      movq %rax, %rcx
      addq $16, %rcx
      addq 8(%rax), %rcx

      movq $UNUSED, %r9
      movq %r9, (%rcx)
      movq %rbx, %rsi 
      subq %rdx, %rsi # %rsi = y - (N + 16)
      movq %rsi, 8(%rcx)
      jmp endForMem
    endIf16:
    cmpq %rbx, %rdi # N < Y
    jg endIfY
      movq $USED, %r9
      movq %r9, (%rax)

      movq %rax, %r10
      addq $16, %r10
      jmp endForMem

    endIfY:
    endIfUsed:
    movq 8(%rax), %rbx
    addq %rbx, %rax
    addq $16, %rax
    jmp forMem
  endForMem:
    # if 10 == 0, expandir

    movq %r10, %rax
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
