INCLUDE Irvine32.inc
.386
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
; Random functions were not learned in class (Randomize & RandomRange)
; I had to find a way to create RNG and luckily Irvine has one

.data
balance DWORD 100 ; how much the player starts with

; message to explain game and rules
greet BYTE "Welcome to the Casino! Where money is pratically free! ", 0Dh, 0Ah
   BYTE "We'll give you 100 dollars to start for free (*^_^*)", 0Dh, 0Ah, 0
balStatement BYTE "You're current balance is: ", 0
greet2 BYTE 0Dh, 0Ah, "Type g to gamble or l to leave if you're a coward! ", 0
buffer BYTE 2 DUP(?), 0 ; has to one bigger than expected size

betMessage1 BYTE "Your bet is placed!", 0Dh, 0Ah, 0
rand DWORD ?

oddsCeiling DWORD 99

betMessageW BYTE "YOU WON!!! \(@^0^@)/", 0Dh, 0Ah, 0

betMessageL BYTE "Ermmm... You lost it all lol", 0Dh, 0Ah
   BYTE "Anyway, come back when you ain't broke", 0Dh, 0Ah, 0

exitMessage BYTE "Don't forget to come back!! :)", 0Dh, 0Ah, 0

.code
main PROC

; greeting message
MOV EDX, OFFSET greet
call WriteString

CALL Randomize ; sets seed

betLoop:
   ; output balance
   MOV EDX, OFFSET balStatement
   call WriteString
   
   MOV EAX, balance
   call WriteDec

   ; start game options (start with 2: gamble or leave)
   MOV EDX, OFFSET greet2
   call WriteString

   ; take input
   MOV EDX, OFFSET buffer ; point to buffer
   MOV ECX, LENGTHOF buffer - 1
   CALL Readstring

   MOV esi, 0 ; 

   cmp buffer[ESI], 0
   je endloop
   cmp buffer[ESI], 'g' ;
   JNE endloop

   jmp workLoop

; work
workLoop:
   
   ; notify player
   MOV EDX, OFFSET betMessage1
   CALL WriteString ; Maybe also print new balance
   
   ; run calculation
   PUSH EAX
   MOV EAX, oddsCeiling
   call RandomRange ; Gets a random number in range 0 - (EAX-1)
   MOV rand, EAX
   POP EAX
   
   ; win lose branch
   PUSH ESI
   MOV ESI, 0
   CMP ESI, rand
   POP ESI
   
   JZ  winBet
   JMP loseBet

winBet:
   ; balance is updated
   PUSH EAX
   MOV EAX, balance
   SHL EAX, 1 ; multiply by 2
   ADD EAX, EAX ; double amount
   MOV balance, EAX
   POP EAX
   
   ; change color of screen on win
   CALL celebrate
   
   ; sent back to bet loop
   JMP betLoop

celebrate PROC
   MOV EAX, white * 16 + black ; white background black text
   CALL SetTextColor
   MOV EDX, OFFSET betMessageW
   CALL WriteString
   MOV EAX, 200
   CALL Delay ; delays each win message so it rolls out
   
   MOV EAX, blue * 16 + black
   CALL SetTextColor
   MOV EDX, OFFSET betMessageW
   CALL WriteString
   MOV EAX, 200
   CALL Delay
   
   MOV EAX, yellow * 16 + black
   CALL SetTextColor
   MOV EDX, OFFSET betMessageW
   CALL WriteString
   MOV EAX, 200
   CALL Delay
   
   MOV EAX, white * 16 + black
   CALL SetTextColor
   MOV EDX, OFFSET betMessageW
   CALL WriteString
   MOV EAX, 200
   CALL Delay
   
   MOV EAX, black * 16 + white
   CALL SetTextColor
   MOV EDX, OFFSET betMessageW
   CALL WriteString
   RET
celebrate ENDP

loseBet:
   MOV balance, 0 ; remove balance
   
   MOV EDX, OFFSET betMessageL
   CALL WriteString
   
   ; JMP betLoop
   JMP endloop ; no money left to take so exit

; exit 
endloop:
   ; exit statement
   MOV EDX, OFFSET exitMessage
   call WriteString
   
   MOV EAX, 35000 ; delay exit by n ms
   CALL Delay
   exit

INVOKE ExitProcess,0
main ENDP
END main