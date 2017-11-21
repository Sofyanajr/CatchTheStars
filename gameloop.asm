;=============================================================================
; 32-bit Assembly Example
;
; Example of an initial top-level gameloop framework.
;=============================================================================
IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; CODE
;=============================================================================
CODESEG



PROC drawSprite
ARG @@spritePtr :dword, \
@@dstPtr :dword, \
@@x:dword, \
@@y:dword
LOCAL @@w:dword, @@h:dword
USES eax , ebx , ecx , edx , esi , edi
mov esi  , [ @@spritePtr ]
xor eax , eax
lodsw ; read width in AX
mov [@@w] , eax
lodsw ; read he igh t in AX
mov [@@h] , eax
mov edi , [ @@dstPtr ]
mov eax , [@@y]
mov ebx , 320
mul ebx
add edi , eax
add edi , [@@x] ; EDI po in ts to f i r s t p i x e l
mov ecx , [@@h]
@@drawLine :
push ecx
mov ecx , [@@w] ; need to copy a l in e o f the s p r i t e
rep movsb ; copy from e s i to ed i
add edi , 320
sub edi , [@@w] ; ed i now po in ts to the next l in e in d s t
pop ecx
dec ecx
jnz @@drawLine
ret
ENDP drawSprite

; Procedure to wait for a v-blank event (synchronizes game loop to 60Hz in mode 13h)
PROC waitVBlank
	USES eax, edx

	mov dx, 03dah
	@@waitVBlank_wait1:
	in al, dx
	and al, 8
	jnz @@waitVBlank_wait1
	@@waitVBlank_wait2:
	in al, dx
	and al, 8
	jz @@waitVBlank_wait2
	ret
ENDP waitVBlank

PROC setupVideo
	USES eax

	mov	ax, 13h
	int	10h

	ret
ENDP setupVideo

PROC unsetupVideo
	USES eax

	mov	ax, 03h
	int	10h

	ret
ENDP unsetupVideo

; Procedure to exit the program
PROC exit
	USES eax

	call unsetupVideo
	mov	eax, 4c00h
	int 21h
	ret
ENDP exit

; Procedure to initialize a new game
PROC initGameState
	ret
ENDP initGameState

PROC moveBlock
	ARG amount:dword
	USES eax, edx
mov ah, 9
mov edx, offset moveMsg
int 21h
	ret
ENDP moveBlock

PROC rotateBlock
	USES eax, edx
mov ah, 9
mov edx, offset rotateMsg
int 21h
	ret
ENDP rotateBlock

; Procedure to handle user input
PROC handleUserInput
	USES eax

	mov ah, 01h ; function 01h (test key pressed)
	int 16h		; call keyboard BIOS
	jz @@no_key_pressed
	mov ah, 00h
	int 16h

	; process key code here (scancode in AH, ascii code in AL)
	cmp ah, 01	; scancode for ESCAPE key
	jne	@@n1
	call exit
	jmp @@no_key_pressed

@@n1:
	cmp ah, 77	; arrow right
	jne @@n2
	;call drawSprite, offset _plusblack, 0a0000h ,[mand_x],160 ;Black tekenen op vorige x
	CMP [mand_x], 284

	jg skipadd
	ADD [mand_x], 10 ; x verhogen
	skipadd:
	;call drawSprite, offset _plus, 0a0000h ,[mand_x],160 ; mandje tekenen
	jmp @@no_key_pressed



@@n2:
	cmp ah, 75	; arrow left
	jne @@n3
	;call drawSprite, offset _plusblack, 0a0000h ,[mand_x],160 ;Black tekenen
	CMP [mand_x], 10

	jl skipsub
	SUB [mand_x], 10
	skipsub:
	;call drawSprite, offset _plus, 0a0000h ,[mand_x],160
	jmp @@no_key_pressed

@@n3:
	cmp ah, 80	; arrow down
	jne @@n4
	call moveBlock, 10
	jmp @@no_key_pressed

@@n4:
	cmp ah, 72	; arrow up
	jne @@n5
	call rotateBlock
	jmp @@no_key_pressed

	

@@n5:
@@no_key_pressed:
	ret

ENDP handleUserInput

; Procedure to update the game world status (like enemies, collisions, events, ...)
PROC updateGameState
	USES eax, edx

	inc [gameLoopCounter]

;mov ah, 9
;mov edx, offset pointMsg
;int 21h
	ret
ENDP updateGameState

; Procedure to draw everything on screen
PROC drawAll
	call waitVBlank

	ret
ENDP drawAll

; MAIN Start of program
start:
    sti                             ; Set The Interrupt Flag
    cld                             ; Clear The Direction Flag

    push ds 						; Put value of DS register on the stack
    pop es 							; And write this value to ES

	; Setup and initialization
	call setupVideo
	call initGameState

	; Main game (endless) loop
	@@gameLoop:

 	call drawSprite, offset _bucketblack, 0a0000h ,[mand_x],160
	call handleUserInput
	call drawSprite, offset _bucket, 0a0000h ,[mand_x],160
	call updateGameState
	call drawAll
	call drawSprite ,offset _starblack, 0a0000h, 150, [y_star]
	ADD [y_star], 2
	call drawSprite ,offset _star, 0a0000h, 150, [y_star]

	jmp @@gameLoop

	; Code can never get here

;=============================================================================
; DATA
;=============================================================================
DATASEG
	; Counts the gameloops. Useful for timing and planning events.
	gameLoopCounter		dd 0

	; Debug messages
	moveMsg		db 'moveBlock$'
	rotateMsg	db 'rotateBlock$'
	pointMsg	db '.$'
	mand_x dd 150
	y_star dd 10



;Vierkant tekenen
_bucket dw 26 , 27 ; W = 8 , h = 8
db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
db 8, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 8
db 8, 2, 2, 2, 2, 10, 10, 10, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 10, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 10, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 10, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 10, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8
db 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 2, 2, 10, 2, 10, 10, 10, 2, 8
db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
db 0, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 10, 2, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 10, 2, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 10, 2, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 10, 2, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 10, 2, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 10, 2, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 10, 2, 10, 10, 2, 8, 0, 0
db 0, 0, 8, 10, 10, 2, 2, 10, 10, 10, 10, 2, 10, 10, 2, 2, 2, 2, 2, 10, 2, 10, 2, 8, 0, 0

_bucketblack dw 26 , 27 ; W = 8 , h = 8
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

_star dw 16, 16
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 7 , 7 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 7 , 14 , 14 , 7 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 7 , 14 , 14 , 7 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 7 , 14, 14 , 14 , 14 , 7 , 0 , 0 , 0 , 0 , 0
db 7 , 7 , 7 , 7 , 7 , 7 , 14 , 14 , 14 , 14 , 7 , 7 , 7 , 7 , 7 , 7
db 7 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 7
db 0 , 7 , 14 , 14 , 14 , 14 , 0 , 14 , 14 , 0 , 14 , 14 , 14 , 14 , 7 , 0
db 0 , 0 , 7 , 14 , 14 , 14 , 0 , 14 , 14 , 0 , 14 , 14 , 14 , 7 , 0 , 0
db 0 , 0 , 0 , 7 , 14 , 14 , 0 , 14 , 14 , 0 , 14 , 14 , 7 , 0 , 0 , 0
db 0 , 0 , 0 , 7 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 7 , 0 , 0 , 0
db 0 , 0 , 7 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 7 , 0 , 0
db 0 , 0 , 7 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14 , 7 , 0 , 0
db 0 , 7 , 14 , 14 , 14 , 14 , 14 , 0 , 0 , 14 , 14 , 14 , 14 , 14 , 7 , 0
db 0 , 7 , 14 , 14 , 14 , 7 , 7 , 0 , 0 , 7 , 7 , 14 , 14 , 14 , 7 , 0
db 7 , 14 , 14 , 7 , 7 , 0 , 0 , 0 , 0 , 0 , 0 , 7, 7 , 14 , 14 , 7
db 7 , 7 , 7 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 7 , 7 , 7

_starblack dw 16, 16
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
db 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0



;=============================================================================
; STACK
;=============================================================================
STACK 1000h

END start
