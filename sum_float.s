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
	movq	%rsp, %r8
	movq	$0, %r9

	xorps	%xmm0, %xmm0            # total <- 0.0
	leaq	(%rdi, %rsi, 4), %rbp   # endptr <- F + n

loop:
	cmpq	%rdx, %rsi			# n - i ? 0
	jle endloop
					# cmpq	%rdi, %rbp             
					# jle	endloop                 # while (F < endptr) {
					# addss	(%rdi), %xmm0           #    total += F[0]
					# add	$4, %rdi                #    F++
					# jmp	loop                    # }

	movq	$0, %r9 # reset flag number
is_q_empty:
	cmp %r8, %rsp # head(Q) - tail(Q) ? 0
	jne interpret_flag_num # flag number = 1
	add $1, %r9

is_f_empty:
	cmpq	%rdi, %rbp # endptr - Base pointer ? 0
	jne	interpret_flag_num # if Q and F not empty compare heads
	add		$3, %r9 # flag number = 3
	jmp interpret_flag_num

interpret_flag_num:
	cmp $0, %r9 # both Q and F not empty
	je cmp_heads_for_x
	cmp $1, %r9 # Q empty, F not empty
	je get_x_from_F
	cmp $3, %r9 # Q not empty, F empty
	je get_x_from_Q
	cmp $4, %r9 # both Q and F empty
	je endloop

	cmp $10, %r9 # both Q and F not empty
	je cmp_heads_for_y
	cmp $11, %r9 # Q empty, F not empty
	je get_y_from_F
	cmp $12, %r9 # Q empty, F not empty
	je get_y_from_F
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
	add	$10, %r9 # flag number
	movsd	(%r8), %xmm1 # x = head(Q)
	comiss (%rdi), %xmm1 # head(Q) - head(F) ? 0
	jg dequeue_x_from_F
	leaq -4(%r8), %r8 # set Q head to next elem
	jmp is_q_empty
cmp_heads_for_y:
	movsd	(%r8), %xmm2 # x = head(Q)
	comiss (%rdi), %xmm2 # head(Q) - head(F) ? 0
	jg dequeue_y_from_F
	leaq -4(%r8), %r8 # set Q head to next elem
	jmp loop

get_x_from_F:
	add	$10, %r9
	movsd	(%rdi), %xmm1 # x = head(F)
	add	$4, %rdi	#    F++
	jmp is_q_empty
get_y_from_F:
	movsd	(%rdi), %xmm2 # y = head(F)
	add	$4, %rdi    #    F++
	inc %rdx
	jmp loop	

get_x_from_Q:
	add	$10, %r9
	movsd (%r8), %xmm1
	leaq -4(%r8), %r8
	jmp is_q_empty

get_y_from_Q:
	add	$10, %r9
	movsd (%r8), %xmm2
	leaq -4(%r8), %r8
	jmp loop

dequeue_x_from_F:
	movsd (%rdi), %xmm1 # x = head(F)
	add	$4, %rdi		# F++
	jmp is_q_empty

dequeue_y_from_F:
	movsd (%rdi), %xmm2 # x = head(F)
	add	$4, %rdi		# F++
	inc %rdx
	jmp loop

enqueue:
	addsd %xmm1, %xmm2
	leaq -4(%rsp), %rsp
	movsd %xmm2, (%rsp)
	inc %rdx
	jmp loop

endloop:
	movsd (%rsp), %xmm0
	mov %rcx, %rsp
	pop	%rbp
	ret
