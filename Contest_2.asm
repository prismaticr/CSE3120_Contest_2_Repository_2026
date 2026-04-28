INCLUDE Irvine32.inc
.386
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
; Random functions (Randomize & RandomRange) and PlaySound function was not were not learned in class.
; I had to find a way to create RNG and luckily Irvine has one

.data
; player's total winnings
total SDWORD 0
; player's bet
betCount DWORD ?

; message to explain game and rules
greet BYTE "Welcome to the Casino! Where money is pratically free! ", 0Dh, 0Ah
   BYTE "Each bet is a free $100! Your overall winnings/loses will be tracked.", 0Dh, 0Ah
   BYTE "Don't worry what happens if you leave while in the red :)", 0Dh, 0Ah, 0
totalStatement BYTE "You're current total winnings are: ", 0
greet2 BYTE 0Dh, 0Ah, "Type g to gamble or type l (or anything else) to leave if you're a coward! ", 0
buffer BYTE 2 DUP(?), 0 ; has to one bigger than expected size

betMessage1 BYTE "Your bet is placed!", 0Dh, 0Ah, 0

; receives random num
rand DWORD ?
; determines the odds of gamble (1/oddsCeiling+1)
oddsCeiling DWORD 99

betMessageW BYTE "YOU WON!!! \(@^0^@)/", 0Dh, 0Ah, 0

betMessageL BYTE "Ermmm... You lost it all lol", 0Dh, 0Ah, 0

exitMessage BYTE "Don't forget to come back!! :)", 0Dh, 0Ah, 0

; constants for PlaySound
SND_ASYNC = 1
SND_LOOP = 8
SND_FILENAME = 20000h

; filenames for songs used
lobbyWavFile BYTE "The_Dreamy_Stage_...for_Casinopolis.wav", 0
winWavFile BYTE "and..._Fish_Hits!.wav", 0
letsGoWavFile BYTE "lets-go_-win.wav", 0
loseWavFile BYTE "WSBowlLose.wav", 0
leaveWavFile BYTE "FSN_Midnight_Interval.wav", 0

.code
PlaySound PROTO, pszSound: PTR BYTE, hmod: DWORD, fdwSound: DWORD
INCLUDELIB Winmm.lib

; procedures for each audio file
playLobbyMusic PROC
   INVOKE PlaySound, OFFSET lobbyWavFile, 0, SND_ASYNC OR SND_LOOP OR SND_FILENAME
   RET
playLobbyMusic ENDP

playCelMusic PROC
   INVOKE PlaySound, OFFSET winWavFile, 0, SND_ASYNC OR SND_FILENAME
   RET
playCelMusic ENDP

playCelVClip PROC
	INVOKE PlaySound, OFFSET letsGoWavFile, 0, SND_FILENAME
	RET
playCelVClip ENDP

playLoseClip PROC
   INVOKE PlaySound, OFFSET loseWavFile, 0, SND_FILENAME
   RET
playLoseClip ENDP

playLeaveMusic PROC
   INVOKE PlaySound, OFFSET leaveWavFile, 0, SND_FILENAME
   RET
playLeaveMusic ENDP

stopMusic PROC
   INVOKE PlaySound, 0, 0, 0
   RET
stopMusic ENDP

main PROC

; greeting message
MOV EDX, OFFSET greet
call WriteString

CALL Randomize ; sets seed

betLoop:
   ; play music during bet interlude
   PUSH EAX
   PUSH EDX
   CALL playLobbyMusic
   POP EAX
   POP EDX

   ; output total winnings
   MOV EDX, OFFSET totalStatement ; OFFSET balStatement
   call WriteString
   
   MOV EAX, total
   call WriteInt ; outputs signed value

   ; start game options (start with 2: gamble or leave)
   MOV EDX, OFFSET greet2
   call WriteString

   ; take input
   MOV EDX, OFFSET buffer ; point to buffer
   MOV ECX, LENGTHOF buffer - 1
   CALL Readstring

   MOV esi, 0

   ; set how much is bet
   MOV betCount, 100

   ; Stop interlude music
   PUSH EAX
   PUSH EDX
   CALL stopMusic
   POP EDX
   POP EDX

   cmp buffer[ESI], 0
   je endloop
   cmp buffer[ESI], 'g' ;
   JNE endloop

   jmp workLoop

workLoop:
   
   ; notify player
   MOV EDX, OFFSET betMessage1
   CALL WriteString
   
   ; run calculation
   PUSH EAX
   MOV EAX, oddsCeiling
   call RandomRange ; Gets a random number in range 0 - (EAX-1)
   MOV rand, EAX
   POP EAX
   
   ; win/lose branching
   PUSH ESI
   MOV ESI, 0
   CMP ESI, rand ; 0 = win & anythingElse = lose
   POP ESI
   
   JZ  winBet
   JMP loseBet

winBet:
   ; total is updated
   PUSH EAX
   MOV EAX, betCount
   SHL EAX, 1 ; multiply by 2
   ADD EAX, EAX ; double amount
   ADD total, EAX
   ; set bet to 0
   MOV betCount, 0
   POP EAX
   
   ; change color of screen on win
   CALL celebrate
   
   ; sent back to bet loop
   JMP betLoop

celebrate PROC
   ; play celebration music
   PUSH EAX
   PUSH EDX
   INVOKE playCelMusic
   MOV EAX, 1000
   CALL Delay
   POP EDX
   POP EDX

   PUSH ECX
   MOV ECX, 18
   restart:
      CALL rolling
      loop restart
   POP ECX

   
   MOV EAX, white * 16 + black
   CALL SetTextColor
   MOV EDX, OFFSET betMessageW
   CALL WriteString
   MOV EAX, 200
   CALL Delay
   
   ; bring text back to normal
   MOV EAX, black * 16 + white
   CALL SetTextColor
   CALL Clrscr
   MOV EDX, OFFSET betMessageW
   CALL WriteString

   ; play voice clip
   PUSH EAX
   PUSH EDX
   CALL playCelVClip
   POP EDX
   POP EDX
   RET
celebrate ENDP

rolling PROC; display rolling win messages
   MOV EAX, white * 16 + black
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
   CALL Clrscr
   MOV EDX, OFFSET betMessageW
   CALL WriteString
   MOV EAX, 200
   CALL Delay
   
   RET
rolling ENDP

loseBet:
   ; subtract what was lost
   MOV ECX, betcount
   MOV EAX, total
   SUB EAX, ECX
   MOV total, EAX
   ; set bet to 0
   MOV betCount, 0
   
   PUSH EAX
   PUSH EDX
   CALL playLoseClip
   POP EDX
   POP EDX

   MOV EDX, OFFSET betMessageL
   CALL WriteString
   
   MOV EAX, 200
   CALL Delay
   JMP betLoop

; exit 
endloop:
   ; exit statement
   MOV EDX, OFFSET exitMessage
   call WriteString
   
   
   CALL playLeaveMusic
   exit

INVOKE ExitProcess,0
main ENDP
END main