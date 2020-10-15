; midterm_ALU.s 


            EXPORT  __Vectors
            EXPORT  Reset_Handler
            AREA    vectors, CODE, READONLY

__Vectors   DCD     0x10010000  ; 0x20008000    ; Top of Stack
            DCD     Reset_Handler               ; Reset Handler

RCC_AHB1ENR equ 0x40023830
GPIOA_MODER equ 0x40020000
GPIOB_MODER	equ	0x40020400
GPIOA_ODR	equ 0x40020014
GPIOB_ODR 	equ 0x40020400
GPIOA_IDR 	equ	0x40020010
GPIOB_IDR 	equ	0x40020410
GPIOC_IDR	equ 0x40020810
GPIOB_PUPDR equ 0x4002040C
GPIOC_MODER equ 0x40020800

            AREA    PROG, CODE, READONLY
Reset_Handler
            ldr     r1, =RCC_AHB1ENR    ; enable GPIOA, GPIOB, and GPIOC clocks
            ldr     r2, [r1]
            orr     r2, #7
            str     r2, [r1]
            
            ldr     r1, =GPIOA_MODER    ; set A pins to output mode
            ldr     r2, =0x55555555
            str     r2, [r1]

			ldr     r1, =GPIOB_MODER    ; set B pins to input mode
            ldr     r2, =0x00000000
            str     r2, [r1]
			
			ldr		r1, =GPIOB_PUPDR	; setup pull-up resistors for B pins
			ldr		r2, =0x55555555
			str		r2, [r1]			
			
			ldr		r1, =GPIOC_MODER	; set C pins to input mode
			ldr		r2, =0x00000000
			str		r2, [r1]	


; --------------------------Read first number-----------------------;
L1			ldr		r1, =0x00002000
again_n1	ldr		r2, =GPIOC_IDR		; keep waiting until blue button is pressed
			ldr		r3, [r2]
			tst		r1, r3
			bne		again_n1
			
			ldr		r1, =GPIOB_IDR		
			ldr		r5, [r1]			; read first number
			rsb		r5, r5, #0xFFFFFFFF ; invert bits
			
			mov		r0, #500			; wait - gives time to let go of button
			bl		delay 


; --------------------------Read operation number-----------------------;
			ldr		r1, =0x00002000
again_op	ldr		r2, =GPIOC_IDR		; keep waiting until blue button is pressed
			ldr		r3, [r2]
			tst		r1, r3
			bne		again_op
			
			ldr		r1,	=GPIOB_IDR		
			ldr		r6, [r1]			; read operator
			rsb		r6, r6, #0xFFFFFFFF	; invert bits
			
			mov		r0, #500			; wait - gives time to let go of button
			bl		delay 
			
			
; --------------------------Read second number-----------------------;
			ldr		r1, =0x00002000
again_n2	ldr		r2, =GPIOC_IDR		; keep waiting until blue button is pressed
			ldr		r3, [r2]
			tst		r1, r3
			bne		again_n2
			
			ldr		r1,	=GPIOB_IDR		
			ldr		r7, [r1]			; read second number
			rsb		r7, r7, #0xFFFFFFFF	; invert bits		
			
			
; --------------------------Choose-operation ladder-----------------------;
			and		r6,	r6,	#0x0000000F	; mask out bits we dont care about
			and		r5,	r5,	#0x0000000F	; mask out bits we dont care about
			and		r7,	r7,	#0x0000000F	; mask out bits we dont care about
			
			teq		r6, #0x00000000		; 0000	=	INV
			beq		inversion
			teq		r6, #0x00000001		; 0001	=	ADD
			beq		addition
			teq		r6, #0x00000002		; 0010	=	SUB
			beq		subtraction
			teq		r6,	#0x00000003		; 0011	=	AND
			beq		anding
			teq		r6, #0x00000004		; 0100	=	OR
			beq		orring
			teq		r6, #0x00000005		; 0101	=	NAND
			beq		nanding
			teq		r6, #0x00000006		; 0110	=	NOR
			beq		norring
			eor		r8, r5, r7			; anything else = XOR
			b		output
			
			
; --------------------------Perform operation-----------------------;			
inversion	rsb		r8, r5, #0x0000000F
			b		output
addition	add		r8, r5, r7
			b		output
subtraction	sub		r8, r5, r7
			b		output
anding		and		r8, r5, r7
			b		output
orring		orr		r8, r5, r7
			b		output
nanding		and		r8, r5, r7
			rsb		r8, r8, #0x0000000F
			b		output
norring		orr		r8, r5, r7
			rsb		r8,	r8,	#0x0000000F
			b		output
			
; --------------------------Output & Reset-----------------------;
output		ldr		r1, =GPIOA_ODR
			lsl		r8, #6				; shift to output to ports A6-A10
			str		r8, [r1]			; output
			
			mov		r0, #500			; wait - gives time to let go of button
			bl		delay 
			
			ldr		r1, =0x00002000
again_reset	ldr		r2, =GPIOC_IDR		; keep waiting until blue button is pressed
			ldr		r3, [r2]
			tst		r1, r3
			bne		again_reset
			
			mov		r0, #2000			; wait - gives time to let go of button
			bl		delay 			
			
			ldr		r1, =GPIOA_ODR
			ldr		r8, =0x00000000
			str		r8, [r1]	
			
			b		L1					; loop back up to the top
; delay milliseconds in R0
delay       ldr     r1, =5325
DL1         subs    r1, r1, #1
            bne     DL1
            subs    r0, r0, #1
            bne     delay
            bx      lr
            
            end