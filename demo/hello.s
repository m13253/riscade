; This program is a part of Riscade project.
; Licensed under MIT License.
; See https://github.com/m13253/riscade/blob/master/COPYING for licensing information.

	.org	0xff00

	; s0 = str.seg
	iml	str.seg
	imh	str.seg
	cpt	s0

	; r2 = str
	iml	str
	imh	str
	cpt	r2

loop:
	; r0 = *r2
	cpf	r2
	cpt	r1
	ld	s0

	; if(r0 == '\0') exit()
	tsz
	hlt
cond	tce

	; putchar(r0)
	swp	r1
	clr
	inc
	swp	r1
	out

	; r2 = r2 + 1
	cpf	r2
	inc
	cpt	r2

	; goto loop
	iml	loop
	imh	loop
	cpt	pc

str:
	; "Hello, world!\n"
	.byte	0x48 0x65 0x6c 0x6c 0x6f 0x2c 0x20 0x77 0x6f 0x72 0x6c 0x64 0x21 0x0a
