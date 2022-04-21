.section .data

# variaveis globais
topoInicialHeap: .quad 0
topoHeap: .quad 0
MEM_POOL: .quad 136
lastAddr: .quad 0

str1: .string "Init heap space\n"
strLabels: .string "oc, qtd: %ld, %ld\n" 
str2: .string "topoInit, actualTopo: %ld, %ld\n"
strLAST: .string "lastAddr = %ld\n"
strMANAGER: .string "#"
strUNUSED: .string "-"
strUSED: .string "+"
strENTER: .string "\n"

# constantes

.equ UNUSED, 0
.equ NULL, 0
.equ USED, 1
.equ LABEL_SIZE, 16

.section .text
.globl iniciaAlocador, printTopo, finalizaAlocador, topoInicialHeap, imprimeMapa, alocaMem, liberaMem, printLastAddr

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
  addq $LABEL_SIZE, %rdi
  movq $12, %rax
  syscall
  movq %rax, topoHeap

  # write initial labels
  movq topoInicialHeap, %rax
  movq %rax, lastAddr
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
      cmpq $LABEL_SIZE, %rbx
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
    addq $LABEL_SIZE, %rax
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
      addq $LABEL_SIZE, %r12
      
      # intern for, going from rbx + 8(rbx) + LABEL_SIZE < topoHeap && pos == UNUSED
      forMergeJ: 
        cmpq topoHeap, %r12
        jge endIfMergeUnused 
        # checks if the wanted block is also unused
        movq (%r12), %r10
        cmpq %r10, %r11
        jne endForMergeJ

        # updates last addr
        cmpq %r12, lastAddr
        jne actualMerge
          movq %rbx, lastAddr
        actualMerge:
          movq 8(%rbx), %rdx
          addq 8(%r12), %rdx
          addq $LABEL_SIZE, %rdx
          movq %rdx, 8(%rbx)

          movq 8(%r12), %rdx
          addq %rdx, %r12
          addq $LABEL_SIZE, %r12
          jmp forMergeJ
      endForMergeJ:
    endIfMergeUnused:
    movq 8(%rbx), %rdx
    addq %rdx, %rbx
    addq $LABEL_SIZE, %rbx
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

  # brk <- brk + MEM_POOL + LABEL_SIZE (labels)
  movq topoHeap, %rbx
  movq %rbx, %rdi
  addq MEM_POOL, %rdi
  addq $LABEL_SIZE, %rdi
  movq $12, %rax
  syscall
  movq %rax, topoHeap

  # writing labels
  movq $UNUSED, (%rbx)
  movq MEM_POOL, %rdx
  movq %rdx, 8(%rbx)
  movq %rbx, %rax

  call mergeBlocks

  movq %rax, lastAddr

  popq %rbp
  ret

# rdi <- N
# rsi <- initial value
# rdx <- lastValue 
findNext:
  pushq %rbp
  movq %rsp, %rbp

  movq $NULL, %r13 # return value
  movq %rdi, %r9 # rdi == N
  addq $LABEL_SIZE, %r9 # r9 <- N + LABEL_SIZE
  movq %rsi, %rax # rax <- rsi has the initial iterator value
  forFindNext:
    cmpq %rdx, %rax # rax < %rdx (rdx has the end of the loop)
    jge endForFindNext

    movq $UNUSED, %r14
    cmpq (%rax), %r14
    jne elseIfFindNextUnused
    cmpq 8(%rax), %r9 # N + LABEL_SIZE < y
    jge ifFindNextNY
    ifFindNextBody:
      movq %rax, %r13
      movq %r13, lastAddr
      jmp endForFindNext
    ifFindNextNY:
      cmpq 8(%rax), %rdi # N <= y
      jg elseIfFindNextUnused
      jmp ifFindNextBody
    elseIfFindNextUnused:
      movq 8(%rax), %r14
      addq %r14, %rax
      addq $LABEL_SIZE, %rax
      jmp forFindNext
  endForFindNext:
  movq %r13, %rax
  popq %rbp
  ret

# rdi <- N
# rsi <- valid addr
myMalloc:
  pushq %rbp
  movq %rsp, %rbp

  movq %rdi, %rdx # rdi == N
  addq $LABEL_SIZE, %rdx # rdx == N + LABEL_SIZE
  cmpq 8(%rsi), %rdx  # rdx < y
  jge myMallocIfNY
    movq 8(%rsi), %rcx

    # update labels
    movq $USED, %r13
    movq %r13, (%rsi)
    movq %rdi, 8(%rsi)

    # jump to next labels
    movq %rsi, %r14
    addq $LABEL_SIZE, %r14
    addq %rdi, %r14

    # write next labels
    movq $UNUSED, %r13
    movq %r13, (%r14)
    subq %rdi, %rcx
    subq $LABEL_SIZE, %rcx
    movq %rcx, 8(%r14)

    jmp myMallocReturn
  myMallocIfNY:
    # update current labels
    movq $USED, %r13
    movq %r13, (%rsi)
  myMallocReturn:
  popq %rbp
  ret

firstFit:
  pushq %rbp
  movq %rsp, %rbp

  pushq %rdi
  movq topoInicialHeap, %rsi
  movq topoHeap, %rdx
  call findNext
  popq %rdi

  # if the addr is not valid, we expand
  movq $NULL, %r15
  cmpq %rax, %r15
  jne firstFitMalloc
    # subq $32, %rsp <- precisa? 
    pushq %rbx
    pushq %rdi
    pushq %rdx
    pushq %rsi
    call expandMem
    popq %rsi
    popq %rdx
    popq %rdi
    popq %rbx
    # addq $32, %rsp <- precisa?
    # in %rax, we have a valid addr
  firstFitMalloc:
  movq %rax, %rsi
  call myMalloc

  addq $LABEL_SIZE, %rax

  popq %rbp
  ret

nextFit:
  pushq %rbp
  movq %rsp, %rbp

  pushq %rdi
  movq lastAddr, %rsi
  movq topoHeap, %rdx
  call findNext
  popq %rdi

  # if the addr is invalid, we call the for again
  movq $NULL, %r15
  cmpq %rax, %r15
  jne nextFitMalloc
  
  pushq %rdi
  movq topoInicialHeap, %rsi
  movq lastAddr, %rdx
  call findNext
  popq %rdi

  # if the addr is invalid, we expand
  movq $NULL, %r15
  cmpq %rax, %r15
  jne nextFitMalloc

    # subq $32, %rsp <- precisa? 
    pushq %rbx
    pushq %rdi
    pushq %rdx
    pushq %rsi
    call expandMem
    popq %rsi
    popq %rdx
    popq %rdi
    popq %rbx
    # addq $32, %rsp <- precisa?
    # in %rax, we have a valid addr
  nextFitMalloc:
  movq %rax, %rsi
  call myMalloc

  addq $LABEL_SIZE, %rax

  popq %rbp
  ret

# rdi <- N
bestFit:
  pushq %rbp
  movq %rsp, %rbp

  movq $NULL, %r13
  movq topoInicialHeap, %rax
  forBestFitFindFirst:
    cmpq topoHeap, %rax # rax < topoHeap
    jge endForBestFitFindFirst

    cmpq $UNUSED, (%rax)
    jne endIfBestFitUnusedFindFirst
      cmpq 8(%rax), %rdi # N <= y
      jg endIfBestFitUnusedFindFirst
      
      movq %rax, %r13
      jmp endForBestFitFindFirst
    endIfBestFitUnusedFindFirst:
    movq 8(%rax), %rdx
    addq $LABEL_SIZE, %rdx
    addq %rdx, %rax
    jmp forBestFitFindFirst
  endForBestFitFindFirst:
  # checks if we found the first unused addr
  movq $NULL, %r14
  cmpq %r13, %r14
  je bestFitExpand
    movq 8(%r13), %r14
    subq %rdi, %r14 # r14 <- y - N
  
    movq %r13, %rax
    movq 8(%rax), %rdx
    addq $LABEL_SIZE, %rdx
    addq %rdx, %rax
    forBestFitFindPos:
      cmpq topoHeap, %rax
      jge endForBestFitFindPos
      
      cmpq $UNUSED, (%rax)
      jne forBestFitFindPosIncrement

      cmpq 8(%rax), %rdi # N <= y
      jg forBestFitFindPosIncrement
        movq 8(%rax), %r15
        subq %rdi, %r15

        cmpq %r14, %r15 # r15 < r14
        jge forBestFitFindPosIncrement
          # updates the valid addr for malloc and the difference of sizes
          movq %rax, %r13
          movq %r15, %r14
      forBestFitFindPosIncrement: 
      movq 8(%rax), %rdx
      addq $LABEL_SIZE, %rdx
      addq %rdx, %rax
      jmp forBestFitFindPos
    endForBestFitFindPos:
    
    movq %r13, %rax
    movq %rax, %rsi
    call myMalloc
    
    jmp bestFitReturn
  bestFitExpand:
    pushq %rbx
    pushq %rdi
    pushq %rdx
    pushq %rsi
    call expandMem
    popq %rsi
    popq %rdx
    popq %rdi
    popq %rbx

    movq %rax, %rsi
    call myMalloc
    
  bestFitReturn:
  addq $LABEL_SIZE, %rax
  popq %rbp
  ret

# rdi <- N
alocaMem:
  pushq %rbp
  movq %rsp, %rbp

  call nextFit
  
  popq %rbp
  ret

# rdi <- addr 
liberaMem:
  pushq %rbp
  movq %rsp, %rbp

  subq $LABEL_SIZE, %rdi 
  movq $UNUSED, (%rdi)
  
  call mergeBlocks

  popq %rbp
  ret  

printTopo: 
  pushq %rbp
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

printLastAddr:
  pushq %rbp
  movq %rsp, %rbp

  movq $strLAST, %rdi
  movq lastAddr, %rsi
  movq $0, %rax
  call printf

  popq %rbp
  ret
