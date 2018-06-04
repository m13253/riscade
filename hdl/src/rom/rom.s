; Program file for calculating GCD of A and B

; A: FF:FE
; B: FF:FF

.org 0xfffe

a:	.byte	42
b:	.byte	56

.org 0xff00

; s0:r2 = &a, s0:r3 = &b
	cpf	s2
	cpt	s0
	cpt	r3
	iml	a.low
	cpt	r2

; s0:r4 = a, s0:r5 = b
	cpt	r1
	ld	s0
	cpt	r4
	cpf	r3
	cpt	r1
	ld	s0
	cpt	r5

loop:
; if(a == 0) halt
	cpf	r4
	tsz
	cpf	pc	; halt
	cpt	pc

; if(b == 0) halt
cond	cpf	r5
cond	tsz
	cpf	pc	; halt
	cpt	pc

; r0 = a, r1 = b
cond	cpt	r1
cond	cpf	r4

; r0 = a - b
cond	sub

; if(r0 > 0), i.e. if(a > b)
cond	tss

; a = a - b, *s0:r2 = a
	cpt	r4
	cpf	r2
	cpt	r1
	cpf	r4
	st	s0

; b = a - b, *s0:r3 = b
cond	cpt	r1
cond	clr
cond	sub
cond	cpt	r5
cond	cpf	r3
cond	cpt	r1
cond	cpf	r5
cond	st	s0

; goto loop
cond	tce
	iml	loop
	imh	loop
	cpt	pc

; 41 instructions
; 29 inst per loop

; 10 inst types used
;     cpf cpt
;     iml imh
;     ld st
;     sub
;     tsz tss tce

; 9 registers used
;     r0 r1 r2 r3 r4 r5
;     pc s0 s2=0xff
