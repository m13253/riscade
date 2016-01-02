; This program is a part of Riscade project.
; Licensed under MIT License.
; See https://github.com/m13253/riscade/blob/master/COPYING for licensing information.

	.org	0x0000
num_a:	.byte	0
num_b:	.byte	1
count:	.byte	12

	.org	0xff00
	iml	num_a.seg
	imh	num_a.seg
	cpt	s0

	; print(0)
	clr
	push
	sts
	cpf	pc
	push
	sts
	iml	print
	imh	print
	cpt	pc
cond	tce

	; print(1)
	clr
	inc
	push
	sts
	cpf	pc
	push
	sts
	iml	print
	imh	print
	cpt	pc
cond	tce

L1:
	; while(count != 0) {
	iml	count
	imh	count
	cpt	r1
	ld	s0
	tsz
	iml	L2
	imh	L2
	cpt	pc
cond	tce

	; count = count - 1
	dec
	st	s0

	; r2 = num_a
	iml	num_a
	imh	num_a
	cpt	r1
	ld	s0
	cpt	r2

	; num_a = num_b
	iml	num_b
	imh	num_b
	cpt	r1
	ld	s0
	swp	r1
	iml	num_a
	imh	num_a
	swp	r1
	st	s0

	; num_b = num_b + r2
	swp	r1
	cpf	r2
	add
	swp	r1
	iml	num_b
	imh	num_b
	swp	r1
	st	s0

	; print(num_b)
	push
	sts
	cpf	pc
	push
	sts
	iml	print
	imh	print
	cpt	pc
cond	tce

	; continue
	iml	L1
	imh	L1
	cpt	pc

L2:
	; }
	hlt

; Print a number and a new line
print:
	; r0 + [stack+1]
	cpf	sp
	inc
	cpt	r1
	ld	s1

	; print_decimal(r0)
	push
	sts
	cpf	pc
	push
	sts
	iml	print_decimal
	imh	print_decimal
	cpt	pc
cond	tce

	; putchar('\n')
	clr
	inc
	cpt	r1
	iml	0xa
	out

	; return
	lds
	pop
	pop
	tce
cond	cpt	pc

; This is the same function as decimal.s
; See decimal.s for explanations
print_decimal:
	cpf	sp
	inc
	cpt	r1
	ld	s1
	cpt	r2
	clr
	iml	10
	cpt	r1
	cpf	r2
	div
	cpt	r2
	cpf	sp
	inc
	swp	r1
	st	s1
	cpf	r2
	tsz
	iml	print_L1
	imh	print_L1
	cpt	pc
cond	tce
	push
	sts
	cpf	pc
	push
	sts
	iml	print_decimal
	imh	print_decimal
	cpt	pc
cond	tce
print_L1:
	cpf	sp
	inc
	cpt	r1
	ld	s1
	swp	r1
	clr
	imh	0x3
	or
	swp	r1
	clr
	inc
	swp	r1
	out
	lds
	pop
	pop
	tce
cond	cpt	pc
