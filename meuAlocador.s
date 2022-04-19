.section .data

# variaveis globais
topoInicialHeap: .quad 0
topoHeap: .quad 0
MEM_POOL: .quad 100

str1: .string "Init heap space\n"
strLabels: .string "oc, qtd: %ld, %ld\n" 
str2: .string "topoInit, actualTopo: %ld, %ld\n"
strMANAGER: .string "#"
strUNUSED: .string "-"
strUSED: .string "+"
strENTER: .string "\n"

#constantes

.equ UNUSED, 0
.equ USED, 1

.section .text
.globl iniciaAlocador, printTopo, finalizaAlocador, topoInicialHeap, imprimeMapa, alocaMem

iniciaAlocador: 
  pushq %rbp
  movq %rsp, %rbp

  # printf to adjust brk's value
  movq $0, %rax
  movq $str1, %rdi
  call printf

  # get current brk value
  movq $0, %rdi
  movq $12, %rax
  syscall
  movq %rax, topoInicialHeap

  # sets the first mem pool
  movq %rax, %rdi
  addq MEM_POOL, %rdi
  addq $16, %rdi
  movq $12, %rax
  syscall
  movq %rax, topoHeap

  # write initial labels
  movq topoInicialHeap, %rax
  movq $UNUSED, (%rax)
  movq MEM_POOL, %rbx
  movq %rbx, 8(%rax)

  popq %rbp
  ret

finalizaAlocador:
  pushq %rbp
  movq %rsp, %rbp

  # sets brk to topoInicialHeap
  movq topoInicialHeap, %rdi
  movq $12, %rax
  syscall

  popq %rbp
  ret

imprimeMapa:
  pushq %rbp
  movq %rsp, %rbp 

  # extern for going from the first block to the last
  movq topoInicialHeap, %rax
  forImprime:
    cmpq topoHeap, %rax
    jge endForImprime

    # for to print hashtags
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

    # condition that decides if - or + needs to be printed
    movq $UNUSED, %rbx
    cmpq (%rax), %rbx
    je elseImprime
    movq $strUSED, %rdx
    jmp endIfImprime
    elseImprime:
      movq $strUNUSED, %rdx
    endIfImprime:

    # for to print - or +
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

    # prints \n
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

mergeBlocks:
  pushq %rbp
  movq %rsp, %rbp

  movq $0, %r15
  movq topoInicialHeap, %rbx
  # extern for, going from topoInicialHeap to topoHeap
  forMerge: 
    cmpq topoHeap, %rbx
    jge endForMerge

    movq (%rbx), %r10
    movq $UNUSED, %r11
    cmpq %r10, %r11
    # checks if the current pos == UNUSED
    jne endIfMergeUnused 
      movq %rbx, %r15
      movq %rbx, %r12
      addq 8(%rbx), %r12
      addq $16, %r12
      
      # intern for, going from rbx + 8(rbx) + 16 < topoHeap && pos == UNUSED
      forMergeJ: 
        cmpq topoHeap, %r12
        jge endIfMergeUnused 
        movq (%r12), %r10
        cmpq %r10, %r11
        jne endForMergeJ

        movq 8(%rbx), %rdx
        addq 8(%r12), %rdx
        addq $16, %rdx
        movq %rdx, 8(%rbx)

        movq 8(%r12), %rdx
        addq %rdx, %r12
        addq $16, %r12
        jmp forMergeJ
      endForMergeJ:
    endIfMergeUnused:
    movq 8(%rbx), %rdx
    addq %rdx, %rbx
    addq $16, %rbx
    jmp forMerge
  endForMerge:
  movq $0, %r14
  cmpq %r15, %r14
  je mergeReturn
    movq %r15, %rax
  mergeReturn:
  popq %rbp
  ret

expandMem:
  pushq %rbp
  movq %rsp, %rbp

  # MEM_POOL <- MEM_POOL * 2
  movq $2, %rax
  movq MEM_POOL, %rbx
  imul %rbx
  movq %rax, MEM_POOL

  # brk <- brk + MEM_POOL + 16 (labels)
  movq topoHeap, %rbx
  movq %rbx, %rdi
  addq MEM_POOL, %rdi
  addq $16, %rdi
  movq $12, %rax
  syscall
  movq %rax, topoHeap

  # writing labels
  movq $UNUSED, (%rbx)
  movq MEM_POOL, %rdx
  movq %rdx, 8(%rbx)
  movq %rbx, %rax

  call mergeBlocks

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
    movq $0, %r15 
    cmpq %r10, %r15
    jne endIfReturn
    
    pushq %rbx
    pushq %rdi
    pushq %rdx
    pushq %rsi
    call expandMem
    popq %rsi
    popq %rdx
    popq %rdi
    popq %rbx

    jmp forMem
    endIfReturn:
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
