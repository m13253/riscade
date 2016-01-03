; This program is a part of Riscade project.
; Licensed under MIT License.
; See https://github.com/m13253/riscade/blob/master/COPYING for licensing information.

	.org	0x0100
number:
	.byte	0

	.org	0xff00
	; s0 = number.seg
	iml	number.seg
	imh	number.seg
	cpt	s0

loop:
	; r0 = number
	iml	number
	imh	number
	cpt	r1
	ld	s0

	; func(r0)
	push
	sts
	cpf	pc
	push
	sts
	iml	func
	imh	func
	cpt	pc
cond	tce

	; putchar(' ')
	clr
	inc
	cpt	r1
	clr
	imh	0x2
	out

	; r0 = number + 1
	; number = r0
	iml	number
	imh	number
	cpt	r1
	ld	s0
	inc
	st	s0

	; if(r0 == 0) {
	tsz

	; putchar('\n')
	clr
	inc
	cpt	r1
	iml	0xa
	out

	; exit()
	hlt

	; }
cond	tce

	; goto loop
	iml	loop
	imh	loop
	cpt	pc

func:
	; r2 = stack[+1]
	cpf	sp
	inc
	cpt	r1
	ld	s1
	cpt	r2

	; r1 = 10
	clr
	iml	10
	cpt	r1

	; r2 = r2 / r1
	; stack[+1] = r2 % r1
	cpf	r2
	div
	cpt	r2
	cpf	sp
	inc
	swp	r1
	st	s1

	; if(r2 != 0) {
	cpf	r2
	tsz
	iml	if
	imh	if
	cpt	pc
cond	tce

	; func(r2)
	push
	sts
	cpf	pc
	push
	sts
	iml	func
	imh	func
	cpt	pc
cond	tce

	; }
if:

	; r0 = stack[+1]
	cpf	sp
	inc
	cpt	r1
	ld	s1

	; putchar(r0 | 0x30)
	swp	r1
	clr
	imh	0x3
	or
	swp	r1
	clr
	inc
	swp	r1
	out

	; return
	lds
	pop
	pop
	tce
cond	cpt	pc
