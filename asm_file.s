.globl slow_pow, hash, prefix_function_asm2, prefix_function_asm_fast_prep, prefix_function_asm_fast_post
.text
slow_pow:
    xorq %rax,%rax
    movsd (%rdi), %xmm0
    movsd %xmm0, %xmm1
    movq (%rsi), %rcx
    subq $1, %rcx
power_slow:
    mulsd %xmm1,%xmm0
    loopq power_slow
    ret

prefix_function_asm2:
    #rsi, rdi - constant pointer for char and int arrays
    movb (%rdi), %al
    movq (%rsi), %r8 # res_len 
    movq (%rdx), %r9 # str_len
    movq (%rcx), %r11 # pi[i]
    movq $1, %r10 # i
    xorq %rdx, %rdx
    movb %al, %dl # str[i]
    xorq %rax,%rax
    addq $1, %rax
outer_for:
    movq %r10,%r13 
    subq $1, %r13  #i-1
    movq %r13, %rsi
    movq (%rcx,%rsi, 8),%r15
    
    
inner_while:
    cmpq $0, %r15 # r-l, c>0
    jle end_while
    movb (%rdi,%r15), %r13b
    cmpb %r13b, %dl # str[i]!= str[c]
    je end_while
    subq $1, %r15
    
    movq (%rcx,%r15, 8),%r15
    
    jmp inner_while
end_while:
    movb (%rdi,%r15), %r13b
    cmpb %dl, %r13b # str[i] == str[c]
    jne not_equal
    movq %r10,%rsi # i
    addq $1,%r15
    movq %r15, (%rcx,%rsi, 8)
    
not_equal:
    addq $1, %r10 # i++
    cmp %r9, %r10 # i!=str_len
    jz postprocessing

    movq %rdi, %r12 
    addq %r10, %r12 #r12 not used more
    movb (%r12), %dl # new str[i]
    jmp outer_for
postprocessing:
    xorq %rsi, %rsi #i
    xorq %rax, %rax #j
ending_for:
    cmpq (%rcx,%rsi, 8),%r8
    jnz not_equal_res
    movq %rsi, %r13 # r13 as buffer
    movq %rsi, %r14 # r14 as result
    movq %rax,%rsi # make rsi as j
    subq %r8, %r14
    subq %r8, %r14
    movq %r14,(%rcx,%rsi, 8)
    movq %r13, %rsi #revert rsi as i
    addq $1, %rax
not_equal_res:
    addq $1, %rsi # i++
    cmp %r9, %rsi # i!=str_len
    jz return
    jmp ending_for
return:
    #movq %rsi,%rax
    ret



prefix_function_asm_fast_prep:
    #rsi, rdi - constant pointer for char and int arrays
    
    movb (%rdi), %al 
    movq (%rsi), %r9 # res_len
    movq (%rcx), %r11 # pi[i]
    movq $1, %r10 # i
    xorq %rdx, %rdx
    movb %al, %dl # substr[i]
    xorq %rax,%rax
    addq $1, %rax
outer_for_prep:
    movq %r10,%r13 
    subq $1, %r13  #i-1
    movq %r13, %rsi
    movq (%rcx,%rsi, 8),%r15
    
    
inner_while_prep:
    cmpq $0, %r15 # r-l, c>0
    jle end_while_prep
    movq %r15,%rsi
    movb (%rdi,%r15), %r13b
    cmpb %r13b, %dl # str[i]!= str[c]
    je end_while_prep
    subq $1, %r15
    movq (%rcx,%r15, 8),%r15
    jmp inner_while_prep
end_while_prep:
    movq %r15,%rsi
    movb (%rdi,%r15), %r13b
    cmpb %dl, %r13b # str[i] == str[c]
    jne not_equal_prep
    movq %r10,%rsi # i
    addq $1,%r15
    movq %r15, (%rcx,%rsi, 8)
    
not_equal_prep:
    addq $1, %r10 # i++
    cmp %r9, %r10 # i!=str_len
    jz return_prep

    movq %rdi, %r12 
    addq %r10, %r12 #r12 not used more
    movb (%r12), %dl # new str[i]
    jmp outer_for_prep

return_prep:
    movq $0,%rax
    ret


prefix_function_asm_fast_post:
    #rdi, rcx, r14- constant pointer for char(string), int array(pi) and char
    movb (%rdi), %al
    movq %r8, %r14 #substr pointer
    movq (%rsi), %r8 # res_len 
    movq (%rdx), %r9 # str_len
    #movq (%rcx), %r11 # pi[i]
    #movq 
    movq $1, %r10 # i
    addq %r8, %r10 # i= res_len+1
    xorq %r11, %r11 # j = 0
    xorq %rdx, %rdx
    movb %al, %dl # str[i]
    xorq %rax,%rax
    addq $1, %rax
    
outer_for_post:
    movq %r10,%r13 
    subq $1, %r13  #i-1
    movq (%rcx,%r13, 8),%r15 # c = pi[i-1]
    
    
inner_while_post:
    cmpq %r15, %r8 # c == res_len
    je inner_while_post_success
    cmpq $0, %r15 # r-l, c>0
    jle end_while_post
    #r13 r12 not used
    movb (%rdi,%r11), %r13b
    movb (%r14,%r15), %r12b
    cmpb %r12b, %r13b # str[j]!= substr[c]
    je end_while_post
inner_while_post_success:
    subq $1, %r15
    movq (%rcx,%r15, 8),%r15
    jmp inner_while_post
end_while_post:
    #movq %r15,%rsi
    #movb (%rdi,%r15), %r13b
    
    movb (%rdi,%r11), %r13b
    movb (%r14,%r15), %r12b
    cmpb %r12b, %r13b # str[j]== substr[c]
    jne not_equal_post
    addq $1,%r15
    movq %r15, (%rcx,%r10, 8)
    
not_equal_post:
    addq $1, %r11 # j++
    addq $1, %r10 # i++
    cmp %r11, %r9 # j!=str_len
    jz postprocessing_post

    #movq %rdi, %r12 
    #addq %r10, %r12 #r12 not used more
    #movb (%r12), %dl # new str[i]
    jmp outer_for_post
postprocessing_post:
    xorq %rsi, %rsi #i
    xorq %rax, %rax #j
    addq %r8,%r9
    addq $1,%r9
ending_for_post:
    cmpq (%rcx,%rsi, 8),%r8
    jnz not_equal_res_post
    movq %rsi, %r13 # r13 as buffer
    movq %rsi, %r14 # r14 as result
    movq %rax,%rsi # make rsi as j
    subq %r8, %r14
    subq %r8, %r14
    movq %r14,(%rcx,%rsi, 8)
    movq %r13, %rsi #revert rsi as i
    addq $1, %rax
not_equal_res_post:
    addq $1, %rsi # i++
    cmp %r9, %rsi # i!=str_len
    jz return_post
    jmp ending_for_post
return_post:
    #movq %rsi,%rax
    ret
