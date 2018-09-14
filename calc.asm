%include "asm_io.inc"
segment .data
;========== Prompts ==========
	title		db	"Welcome to the calculator program!",0
	firstNum	db	"Enter your first number:  ",0
	secondNum	db	"Enter your second number:  ",0
	selection	db	"Choose an operation to perform {addition(+), subtraction(-), multiplication(*), division(/), modulo(%), or power(^)}:  ",0

	current		db	"Selected Operation: ", 0

	addition	db	"The sum is: ",0
	subtraction	db	"The difference is: ",0
	multiplication	db	"The product is: ",0
	division	db	"The quotient is: ",0
	modulo		db	"The modulus is: ",0
	power		db 	"The value is: ",0
	 
;========== Variable Declarations ===========	
	number1	dd 0		;Variable to hold the first number inputted
	number2 dd 0		;Variable to hold the second number inputted
	operation dw "", 0	;Variable to hold the operation inputted (initalized to nothing)

segment .bss


segment .text
	global  asm_main

asm_main:
	enter	0,0		; setup routine
	pusha
	;***************CODE STARTS HERE***************************
	
;########## Title ##########
	mov eax, 0			;Clear out eax
	mov eax, title			;Copy the title prompt into eax
	call print_nl			;Newline
	call print_string		;Print out the title prompt
	call print_nl			;Newline
	call print_nl			;Newline

;########## First Number ##########
	mov eax, 0			;Clear out eax again
	mov eax, firstNum		;Copy the firstNum prompt to eax
	call print_string		;Ask the user for the first number
	mov eax, 0			;Clear out eax so the number isn't corrupted 
	call read_int			;Read in the first number	
	mov [number1], eax		;Copy the value in eax to the number1 variable

;########## Operator ########## 
	call print_nl			;Newline
        mov eax, 0                      ;Clear out eax again
        mov eax, selection              ;Copy the selection prompt to eax
        call print_string               ;Ask the user for the operator
        mov eax, 0                      ;Clear out eax
	call read_char			;Clear the input (newline character)
        call read_char                  ;Read the character (operator)
        mov [operation], eax            ;Copy the value in eax to the operation variable


;########## Second Number ##########
	call print_nl			;Newline
        mov eax, 0                      ;Cear out eax
        mov eax, secondNum              ;Copy the secondNum prompt to eax
        call print_string               ;Ask the user for their second number
        mov eax, 0                      ;Clear out eax
        call read_int                   ;Read in the number
        mov [number2], eax               ;Copy the number into the number2 variable


;######### Add the Numbers & Operation to the Stack ##########
	push DWORD [number2]		;Push number2 on (DWORD because dd size)			
	push operation			;Push the operator onto the stack
	push DWORD [number1]		;Push number1 on (DWORD because dd size)

;######### Compare the Operator ##########
	call print_nl			;Newline
	mov eax, 0			;Clear out eax

;***** Addition Checker *****
	cmp BYTE[operation], '+'	;Compare esi to +
	je additionCaller		;If it is equal, jump to additionCaller

;***** Subtraction Checker *****
	cmp BYTE[operation], '-'	;Compare esi to -
	je subtractionCaller		;If it is equal, jump to subtractionCaller

;***** Multiplication Checker *****
	cmp BYTE[operation], '*'		;Compare esi to *
	je multiplicationCaller		;If it is equal, jump to multiplicationCaller

;***** Division Checker *****
	cmp BYTE[operation], '/'		;Compare esi to /
	je divisionCaller		;If it is equal, jump to divisionCaller	

;***** Modulo Checker *****
	cmp BYTE[operation], '%'		;Compare esi to %
	je moduloCaller			;If it is equal, jump to moduloCaller
	
;***** Power Checker *****
	cmp BYTE[operation], '^'		;Compare esi to ^
	je powerCaller			;If it is equal, jump to powerCaller


;########## Function Calls ##########
	additionCaller:
		call addFunction	;Call the addition function... 
		jmp end			;Jump to the end when finished
	
	subtractionCaller:
		call subFunction	;Call the subtraction function
		jmp end                 ;Jump to the end when finished

	multiplicationCaller:
		call mulFunction	;Call the multiplication function
		jmp end                 ;Jump to the end when finished

	divisionCaller:
		call divFunction	;Call the division function
		jmp end                 ;Jump to the end when finished
	
	moduloCaller:	
		call moduloFunction	;Call the modulus function
		jmp end                 ;Jump to the end when finished

	powerCaller:
		call powerFunction	;Call the power function
		jmp end                 ;Jump to the end when finished


;########## End / Print ##########
	end:
		call print_int		;Print out the value in eax
		call print_nl		;Newline
		call print_nl		;Newline
		add esp, 12		;Reset/fix esp


	;***************CODE ENDS HERE*****************************
	popa
	mov	eax, 0		; return back to C
	leave
	ret

;########## Addition Function ##########
addFunction:
	;***** PROLOGUE *****
	push ebp			;Push ebp onto the stack to hold the top position
	mov ebp, esp			;Copy the value stored in esp to ebp

	;***** Print Out *****
	call startPrint			;Call the startPrint function

	;***** Addition *****
	call moveVals			;Call the moveVals function... 
	add ebx, ecx			;Add ebx to ecx.  The value is in ebx
	mov eax, ebx			;Copy the value in ebx to eax 	

	;***** EPILOGUE *****
	mov esp, ebp			;Copy the value in ebp to esp
	pop ebp				;Pop off ebp (remove it from the stack)
	ret				;Return


;########## Subtraction Function ##########
subFunction:
 ;***** PROLOGUE *****
        push ebp                        ;Push ebp onto the stack to hold the top position
        mov ebp, esp                    ;Copy the value stored in esp to ebp

        ;***** Print Out *****
	call startPrint			;Call the startPrint function

        ;***** Subtraction *****
	call moveVals			;Call the moveVals function...
	sub ebx, ecx			;Subtract ecx from ebx (number1-number2)
	mov eax, ebx			;Copy the value to eax

        ;***** EPILOGUE *****
        mov esp, ebp                    ;Copy the value in ebp to esp
        pop ebp                         ;Pop off ebp (remove it from the stack)
        ret                             ;Return


;########## Multiplication Function ##########
mulFunction:
 ;***** PROLOGUE *****
        push ebp                        ;Push ebp onto the stack to hold the top position
        mov ebp, esp                    ;Copy the value stored in esp to ebp

        ;***** Print Out *****
	call startPrint			;Call the startPrint function

        ;***** Multiplication *****
	call moveVals			;Call the moveVals function...
	mov eax, [ebp+16]		;Copy the second number (number2) to eax since
						;mul will multiply ebx * eax not ecx
	mul ebx				;Multiply ebx, automatically stores value in eax

        ;***** EPILOGUE *****
        mov esp, ebp                    ;Copy the value in ebp to esp
        pop ebp                         ;Pop off ebp (remove it from the stack)
        ret                             ;Return

;########## Division Function ###########
divFunction:
 ;***** PROLOGUE *****
        push ebp                        ;Push ebp onto the stack to hold the top position
        mov ebp, esp                    ;Copy the value stored in esp to ebp

        ;***** Print Out *****
	call startPrint			;Call the startPrint function
	
        ;***** Division *****
	call moveVals			;Call the moveVals function...
	mov eax, [ebp+8]		;Copy the first number (number1) into eax
	mov ebx, [ebp+16]		;Copy the second number (number2) into ebx

	div ebx				;Call divide on ebx (same as eax = eax/ebx)
	mov ecx, 0			;Clear out all of ecx
	mov cx, ax			;Copy the divided number (in ax) to cx
	movzx eax, cx			;Move the answer into eax, with the remainder filled with zeros 

        ;***** EPILOGUE *****
        mov esp, ebp                    ;Copy the value in ebp to esp
        pop ebp                         ;Pop off ebp (remove it from the stack)
        ret                             ;Return

moduloFunction:
 	;***** PROLOGUE *****
        push ebp                        ;Push ebp onto the stack to hold the top position
        mov ebp, esp                    ;Copy the value stored in esp to ebp

        ;***** Print Out *****
	call startPrint			;Call the startPrint function	

        ;***** Modulus *****
	call moveVals			;Call the moveVals function..
	mov eax, [ebp+8]		;Copy the first number into eax (number1)
	mov ebx, [ebp+16]		;Copy the second number into ebx (number2)

	div bl				;Call divide on bl (same as al = al/bl)
	mov al, ah			;Copy the value in ah to al (the remainder/mod)
	mov ah, 0			;Zero out ah so that it doesn't print garbage

        ;***** EPILOGUE *****
        mov esp, ebp                    ;Copy the value in ebp to esp
        pop ebp                         ;Pop off ebp (remove it from the stack)
        ret                             ;Return

powerFunction:
 ;***** PROLOGUE *****
        push ebp                        ;Push ebp onto the stack to hold the top position
        mov ebp, esp                    ;Copy the value stored in esp to ebp

        ;***** Print Out *****
	call startPrint			;Call the startPrint function
	
        ;***** Power *****
	call moveVals			;Call the moveVals function...
	mov eax, [ebp+8]		;Copy the first number into eax

	cmp ecx, 0			;If ecx == 0...
	je endCondition			;Jump to the zero condition

	cmp ecx, 1			;If ecx == 1...
	je oneCondition			;Jump to the one condition

	sub ecx, 1			;Subtract 1 from ecx
	;ecx has the value of number2, so it will loop powerLooper that many times
	powerLooper:
		mul ebx			;Multiply ebx (same as eax = ebx*eax)
		loop powerLooper	;Loop back through powerLooper  

	endPower:
        ;***** EPILOGUE *****
        mov esp, ebp                    ;Copy the value in ebp to esp
        pop ebp                         ;Pop off ebp (remove it from the stack)
        ret                             ;Return

endCondition:
	mov eax, 0			;Zero out eax
	mov eax, 1			;Put 1 into eax because n^0 = 1
	jmp endPower			;Jump to the endPower sign

oneCondition:
	jmp endPower			;Jump to the end, since n^1 = n	
	
startPrint:
 ;***** Print Out *****
        call print_nl                   ;Newline
        mov eax, 0                      ;Clear eax
        mov eax, current                ;Copy the current string into eax
        call print_string               ;Print out "Selected Operation"
        mov eax, 0                      ;Clear out eax again
	mov eax, [number1]              ;Move the first number into eax
        call print_int                  ;Print out the first number
	mov eax, [operation]            ;Move the operation into eax
        call print_char                 ;Print out the operation
        mov eax, [number2]              ;Move the second number into eax
        call print_int                  ;Print out the second number
	mov eax, '='			;Move an equal sign into eax
	call print_char 		;Print out the equal sign
        call print_nl                   ;Newline
	ret
	
moveVals:
	mov eax, 0			;Clear out eax
	mov ebx, 0			;Clear out ebx
	mov ecx, 0			;Clear out ecx
	
	mov ebx, [ebp+8]		;Copy the first number (number1) into ebx
	mov ecx, [ebp+16]		;Copy the second number (number2) into ecx
	ret
