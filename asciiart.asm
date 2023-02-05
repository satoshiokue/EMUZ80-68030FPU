	CPU	68030
    FPU ON
	SUPMODE	ON

ACIAC:	EQU	$0000E001
ACIAD:	EQU	$0000E000

	ORG		$00008000
	MOVE.l	#$00000001,d0
	MOVEC	d0,CACR
start:
	move.w	#-12,d1			; Y = -12
loop_y:
	move.w	#-39,d2			; X = -39
loop_x:
	fmove.d	#0.0458,fp0
	fmove.w	d2,fp2
	fmove.d	#0.08333,fp1
	fmove.w	d1,fp3
	nop

	fmul.x	fp2,fp0			; CA=X*0.0458
	nop
	nop
	fmul.x	fp3,fp1			; CB=Y*0.08333
	nop
	nop

	fmove.x	fp0,fp2			; A(fp2)=CA
	fmove.x	fp1,fp3			; B(fp3)=CB

	move.w	#0,d3			; I=0
loop_i:
	fmove.x	fp2,fp4			; fp4=A(fp2)
	fmul.x	fp4,fp4			; fp4=A*A
	fmove.x	fp3,fp5			; fp5=B(fp3)
	fmul.x	fp5,fp5			; fp5=B*B

	fmove.x	fp4,fp6			; fp6=A*A
	fsub.x	fp5,fp6			; A*A-B*B
	fadd.x	fp0,fp6			; T=A*A-B*B+CA

	fmove.x	fp2,fp7			; fp7=A(fp2)
	fmul.x	#2,fp7			; 2*A
	fmul.x	fp3,fp7			; 2A*B
	fadd.x	fp1,fp7			; fp7=2*A*B+CB
	fmove.x	fp7,fp3			; B(fp3)=fp7
	fmove.x	fp6,fp2			; A(fp2)=fp6
	fmul.x	fp6,fp6			; A*A
	fmul.x	fp7,fp7			; B*B
	fadd.x	fp6,fp7			; fp7=A*A+B*B

	nop
	nop
	nop

	fcmp.d	#4,fp7
	fbgt	L_200

	addq.w	#1,d3
	cmp.w	#16,d3
	bne		loop_i

	move.b	#' ',d0
	bsr		CONOUT
	bra		L_210

L_200:
	cmp.w	#10,d3
	bcs		L_205
	addq.w	#7,d3
L_205:
	move.b	#'0',d0
	add.b	d3,d0
	bsr		CONOUT
L_210:
	addq.w	#1,d2
	cmp.w	#40,d2
	bne		loop_x

	move.b	#13,d0
	bsr		CONOUT
	move.b	#10,d0
	bsr		CONOUT
	addq.w	#1,d1
	cmp.w	#13,d1
	bne		loop_y

	bra		start
	dc.b	$4a,$fc
	rts

CONOUT:
	SWAP	D0
CO0:
	MOVE.B	ACIAC,D0
	AND.B	#$02,D0
	BEQ	CO0
	SWAP	D0
	MOVE.B	D0,ACIAD
	RTS
