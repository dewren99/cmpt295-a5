	.globl sum_float

	# var map:
	#   %xmm0:  total
	#   %rdi:   F[n] (base pointer)
	#   %rsi:   n
	#   %rbp:   endptr

	#	%rdx:	i
	#	%rcx:	original rsp
	#	%r8:	head of Q
	#	%rsp:	tail of Q
	#	%xmm1:	x
	#	%xmm2:	y
	#	%r9:	flag that holds numbers for conditions

sum_float:
	push	%rbp
	movq	$1, %rdx
	movq	%rsp, %rcx
	leaq	-4(%rsp),%rsp
	movq	%rsp, %r8
	movq	$0, %r9 # flag

	xorps	%xmm0, %xmm0            # total <- 0.0
	leaq	(%rdi, %rsi, 4), %rbp   # endptr <- F + n

loop:
	cmpq	%rdx, %rsi			# n - i ? 0
	jle endloop

is_q_empty:
	cmp 	%rsp, %r8 	# head(Q) - tail(Q) ? 0
	jge	 	is_f_empty 	# Q is not empty
	add 	$1, %r9		# Q is empty set flag # to 1

is_f_empty:
	cmpq	%rdi, %rbp # endptr - Base pointer ? 0
	jg		interpret_flag_num # if Q and F not empty compare heads
	add		$3, %r9 # flag number = 3
	jmp interpret_flag_num

interpret_flag_num:
	cmp $0, %r9 # both Q and F not empty
	je cmp_heads_for_x
	cmp $1, %r9 # Q empty, F not empty
	je dequeue_x_from_F
	cmp $3, %r9 # Q not empty, F empty
	je get_x_from_Q
	cmp $4, %r9 # both Q and F empty
	je endloop

	cmp $10, %r9 # both Q and F not empty
	je cmp_heads_for_y
	cmp $11, %r9 # Q empty, F not empty
	je dequeue_y_from_F
	cmp $12, %r9 # Q empty, F not empty
	je dequeue_y_from_F
	cmp $13, %r9 # Q not empty, F empty
	je get_y_from_Q
	cmp $14, %r9 # both Q and F empty
	je endloop
	cmp $15, %r9 # both Q and F empty
	je endloop
	cmp $16, %r9 # Q not empty. F empty
	je get_y_from_Q
	cmp $17, %r9 # both Q and F empty
	je endloop

cmp_heads_for_x:
	movss	(%r8), %xmm3 # x = head(Q)
	comiss (%rdi), %xmm3 # head(Q) - head(F) ? 0
	jg dequeue_x_from_F
	jmp get_x_from_Q

cmp_heads_for_y:
	movss	(%r8), %xmm3 # x = head(Q)
	comiss (%rdi), %xmm3 # head(Q) - head(F) ? 0
	jg dequeue_y_from_F
	jmp get_y_from_Q

dequeue_x_from_F:
	add	$10, %r9
	movss (%rdi), %xmm1 # x = head(F)
	leaq	4(%rdi), %rdi		# F++
	jmp is_q_empty

dequeue_y_from_F:
	movss (%rdi), %xmm2 # x = head(F)
	leaq	4(%rdi), %rdi		# F++
	jmp enqueue

get_x_from_Q:
	add	$10, %r9
	movss (%r8), %xmm1
	leaq -4(%r8), %r8
	jmp is_q_empty

get_y_from_Q:
	movss (%r8), %xmm2
	leaq -4(%r8), %r8
	jmp enqueue

enqueue:
	addss	%xmm1, %xmm2
	leaq 	-4(%rsp), %rsp
	movss 	%xmm2, (%rsp)
	movq	$0, %r9 # reset flag number
	incq 	%rdx
	jmp 	loop

endloop:
	movss 	(%rsp), %xmm0
	addss 	(%r8), %xmm0
	jmp 	end

end:
	movq 	%rcx, %rsp
	pop		%rbp
	ret
