;------------------------------------------GORILAS PROJECT----------------------------------------------------------------------------------------------------------


;------------------------------------------EQU'S----------------------------------------------------------------------------------------------------------

IO_escrever     EQU     FFFEh 
iniciar         EQU     FFFFh 
IO_controlo     EQU     FFFCh 
IO_estado		EQU		FFFDh
IO_maskclear	EQU		FFFFh

TIME_CTG	 	EQU		FFF6h
TIME_CTRL	 	EQU 	FFF7h
MASK			EQU		FFFFh 
MASK_INT		EQU 	FFFAh

cabeca          EQU     0001h 
tronco0         EQU     0100h 
tronco1         EQU     0101h 
tronco2         EQU     0102h 
pernaE          EQU     0200h 
espaco          EQU     0201h
pernaD          EQU     0202h 
cursorA         EQU     0000h		;cursor para o angulo
cursorV         EQU     0100h		;cursor para a velocidade
cursorS         EQU     0200h		;cursor para o score
cursorP			EQU		0C14h		;cursor para o pressione etc



;-------------------------------------------------------------------------------------------------------------------------------------------

;-------------------------------------------------MEMORIA-----------------------------------------------------------------------------------


				ORIG	8000h

X				WORD	5
Y				WORD	6                
TEMPO			WORD	2

Baneners_coord  WORD    0000h   
TABELA      	STR     0000h ,  0004h ,  0009h ,  000dh ,  0012h ,  0016h ,  001bh ,  001fh ,  0024h ,  0028h ,  002ch ,  0031h ,  0035h ,  003ah ,  003eh ,  0042h ,  0047h ,  004bh ,  004fh ,  0053h ,  0058h ,  005ch ,  0060h ,  0064h ,  0068h ,  006ch ,  0070h ,  0074h ,  0078h ,  007ch ,  0080h ,  0084h ,  0088h ,  008bh ,  008fh ,  0093h ,  0096h ,  009ah ,  009eh ,  00a1h ,  00a5h ,  00a8h ,  00abh ,  00afh ,  00b2h ,  00b5h ,  00b8h ,  00bbh ,  00beh ,  00c1h ,  00c4h ,  00c7h ,  00cah ,  00cch ,  00cfh ,  00d2h ,  00d4h ,  00d7h ,  00d9h ,  00dbh ,  00deh ,  00e0h ,  00e2h ,  00e4h ,  00e6h ,  00e8h ,  00eah ,  00ech ,  00edh ,  00efh ,  00f1h ,  00f2h ,  00f3h ,  00f5h ,  00f6h ,  00f7h ,  00f8h ,  00f9h ,  00fah ,  00fbh ,  00fch ,  00fdh ,  00feh ,  00feh ,  00ffh ,  00ffh ,  00ffh ,  00ffh ,  00ffh ,  0100h ,  0100h 

POSX 			WORD	0
POSY			WORD	0
VEL				WORD	0
ANG				WORD	0

EmptySpace      STR     ' '
Banener         STR     '$'
gorila0         STR      'o'
gorila1         STR     '(G)'
gorila2         STR     '/ \'
G_StartPoint    WORD    1500h
G1_StartPoint   WORD    0000h 
present			STR		'Pressione a tecla IA para comecar.'
info			STR		'ANGULO: VELOCIDADE: SCORE: '
botao           WORD    0
digito          WORD    0

;------------------------------------INTERRUPCOES------------------------------------------------------------------------------------------------

				ORIG	FE00h
I0              WORD    botao0
I1              WORD    botao1
I2              WORD    botao2
I3              WORD    botao3
I4              WORD    botao4
I5              WORD    botao5
I6              WORD    botao6
I7              WORD    botao7
I8              WORD    botao8
I9              WORD    botao9
IA              WORD    GAME

                ORIG    FE0Fh                 
INT15			WORD	TEMP
	
    
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-Actual Code-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-	
				ORIG	0000h
				
                MOV R1, iniciar                 ; iniciacao porto de controlo
                MOV M[IO_controlo], R1 

				MOV R1, FDFFh                   ; iniciacao endereço do SP
				MOV SP, R1
				MOV R1, MASK
				MOV M[MASK_INT], R1        ; enable INT15 
		     	ENI                        ; enable interruptions 
				MOV R7, R0
                
                
MAIN:           CALL escreverP   
                CALL espera
                
                
GAME:           CALL limpar                
				CALL printGorila
                CALL introduzinfo
				ENI
                CALL espera_A
                CALL espera_V
                CALL TIME_STARTER
                                
				
Fim:            BR      Fim      

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-¦Ecra Inicial¦=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

escreverP:		ENI
                MOV R2, cursorP
				MOV R3, present
escreveP:		MOV M[IO_controlo], R2
				MOV R4, M[R3]
				MOV M[IO_escrever], R4
				INC R2
				INC R3
				CMP R4, '.'
				BR.NZ escreveP
				RET
 
espera:			BR espera 


limpar:		    MOV R1, IO_maskclear		
				MOV M[IO_controlo], R1
				
				RET
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-¦Ecra Inicial¦=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
				
BananaMotion:	PUSH R0         ;Libertar espaço para output
				PUSH R0
				PUSH M[POSX]    ;Introduzir Vars
				PUSH M[POSY]
				PUSH M[VEL]
				PUSH M[ANG]
				PUSH M[TEMPO]
				CALL TRAJETORIA
				POP M[Y]        ;Guardar output
				POP M[X]
                
                RET
                
	
	
	TRAJETORIA:	PUSH R1         ;Preservar valores dos registos
				PUSH R2
				PUSH R3
				PUSH R4
				
				MOV R1,M[VEL]    ;Colocar Vars nos registos
				SHL R1, 8 
				MOV R2,M[TEMPO]
				 
				MOV R3,M[ANG]
				MOV R4, 90            ;Encontrar cos a partir de sin e por valor em R4
				SUB R4,R3             ;|
				MOV R4, M[R4+TABELA]  ;|
				
				MUL R4,R2           ;cos * tempo : coloca resultado em R4
				SHL R4,8            ;|
				SHR R2, 8           ;|
				OR R4,R2            ;|
				
				MUL R1,R4         ;velocidade*(cos * tempo) : coloca resultado em R4     
				SHL R1,8            ;|
				SHR R4, 8           ;|
				OR R4,R1            ;|
				
				
				MOV M[SP+12],R4   ; colocar valor X no espaco designado na pilha   
				
				POP R4        ;Reaver valores de registos
				POP R3        ;|
			    POP R2        ;|
				POP R1        ;|
				
				PUSH R1       ;Guardar valores dos registos na pilha
				PUSH R2       ;|
				PUSH R3       ;|
				PUSH R4       ;|
				
				MOV R1,M[VEL]         ;Colocar valores para calculo de Y nos registos
				SHL R1, 8 
				MOV R2,M[TEMPO]       ;|
				
				MOV R3,M[ANG]         ;|				 
				MOV R4,M[R3+TABELA]   ;|				
				
				MUL R2,R1       ;velocidade*tempo : coloca resultado em R1
				SHL R2,8            ;|
				SHR R1, 8           ;|
				OR R1,R2            ;|
		 		
				MUL R1,R4       ;sin*velocidade*tempo : coloca resultado em R1
				SHL R1,8        ;|
				SHR R4,8        ;|
				OR R1,R4        ;|
				
				
				MOV R2, M[TEMPO]  ;(tempo)^2 : coloca resultado em R2
				
				MOV R3, M[TEMPO]  ;
				
				MUL R3,R2         ;
				SHL R3,8            ;|
				SHR R2, 8           ;|
				OR R2,R3            ;|
		
				MOV R4,5       ; (gravidade_arredondada)/2 : coloca resultado em R4 
				SHL R4, 8 
				
				MUL R4,R2      ; ((gravidade_arredondada)/2)*((tempo)^2) : coloca resultado em R2
				SHL R4,8            ;|
				SHR R2, 8           ;|
				OR R2,R4            ;|
				
				SUB R1,R2              ;(sin*velocidade*tempo)-((gravidade_arredondada)/2)*((tempo)^2) : coloca resultado em R1
				MOV M[SP+11],R1        ; colocar valor Y no espaco designado na pilha
				
				POP R4             ;Reaver valores de registos     
				POP R3             ;|
				POP R2             ;|
				POP R1             ;|
				RETN 5          ;Retorna a funcao principal e elemina todas as Vars da pilha deixando apenas os valores de X e Y.

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-¦DANGER ! Temporizador Stuff ! Only Authorized Personel Allowed!¦=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 			
; ROTINA DE INICIALIZACAO DO TEMPORIZADOR
			
TIME_STARTER:	PUSH R1
				MOV R1, 1              ; ORIGINA INTERRUPCAO DEPOIS DE 100 ms
				MOV M[TIME_CTG], R1
				MOV R1, 1
				MOV M[TIME_CTRL], R1   ; iniciar contagem 
				POP R1
				RET
                
; ROTINA DE INTERRUPCAO PELO TEMPORIZADOR

TEMP:			PUSH R7
                CALL TIME_STARTER       ; set up stuff for another run     
                
                CALL BananaMotion
                CALL FindCoord
                CALL DrawBaneners
                
                MOV R7, M[TEMPO]
                ADD R7, 0030h                  ; contar fracao de segundo 
				MOV M[TEMPO], R7
                
                
                POP R7 
				RTI
				
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-¦DANGER ! Temporizador Stuff ! Only Authorized Personel Allowed!¦=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                
FindCoord:      PUSH R1                          ; 23*80: dimensoes janela texto 
				PUSH R2
                PUSH R3 
                
                MOV R1, M[Y]                     ;determinar Y bin coord
                SHR R1, 8 
                MOV R2, 23
                SUB R2, R1                       ; Y fica no R2      
                               
                JMP.N    Fim                      ;Y coord Nao pode ser negativa\ WORK IN PROGRESS \ parar de desenhar      !!!!!!!!!!                
                                                    
                
                MOV R1, M[X]                      ; X fica no R1 
                SHR R1, 8 
                MOV R3, 80 
                CMP R3, R1 
                JMP.N   Fim                        ;X coord nao pode ser maior que 80                                         !!!!!!!!!!
                CMP R1,R0
                JMP.N   Fim                        ;X coord nao pode ser negativa                                            !!!!!!!!!                  
                
                
                SHL R2, 8                         ;colocar Y coord nos 8 bits mais significantes 
                
                ADD R2, R1                        ;colocar X coord nos 8 bits menos significantes 
                
                MOV M[Baneners_coord], R2         ;por coords na memoria 
                
                POP R3 
                POP R2
                POP R1 
                RET 
                
DrawBaneners:   PUSH R1 
                
                MOV R1, M[EmptySpace]
                MOV M[IO_escrever], R1 
                
                CALL printGorila
               
                MOV R1, M[Baneners_coord]
                MOV M[IO_controlo], R1         ;dar a conrolo as banana coords
                
                MOV R1, M[Banener]
                MOV M[IO_escrever], R1         ;escrever banana
                
                POP R1 
                
                RET 
                
printGorila:    PUSH R1
                
                MOV R1, M[G_StartPoint]
                ADD R1, cabeca                  ; R1 = posicao da cabeca
                MOV M[IO_controlo], R1            
                
                MOV R1, M[gorila0]              ; escrever cabeca
                MOV M[IO_escrever], R1 
                                
                MOV R1, M[G_StartPoint]              
                ADD R1, tronco0                 ; R1 = posicao do tronco0
                MOV M[IO_controlo], R1          
                
                MOV R1, M[gorila1]              ; escrever tronco0
                MOV M[IO_escrever], R1

                MOV R1, M[G_StartPoint]              
                ADD R1, tronco1                 ; R1 = posicao do tronco1
                MOV M[IO_controlo], R1          
                
                MOV R1, gorila1
                MOV R1, M[R1 + 1]              ; escrever tronco1
                MOV M[IO_escrever], R1

                MOV R1, M[G_StartPoint]              
                ADD R1, tronco2                 ; R1 = posicao do tronco2
                MOV M[IO_controlo], R1          
                
                MOV R1, gorila1
                MOV R1, M[R1 + 2]              ; escrever tronco2
                MOV M[IO_escrever], R1

                MOV R1, M[G_StartPoint]
                ADD R1, pernaE                  ; R1 = posicao da pernaE
                MOV M[IO_controlo], R1  
            
                MOV R1, gorila2
                MOV R1, M[R1]                  ; escrever pernaE
                MOV M[IO_escrever], R1
                
                MOV R1, M[G_StartPoint]
                ADD R1, espaco                  ; R1 = posicao do espaco
                MOV M[IO_controlo], R1  
            
                MOV R1, gorila2
                MOV R1, M[R1 + 1]              ; escrever espaco
                MOV M[IO_escrever], R1
                
                MOV R1, M[G_StartPoint]
                ADD R1, pernaD                  ; R1 = posicao da pernaD
                MOV M[IO_controlo], R1  
            
                MOV R1, gorila2
                MOV R1, M[R1 + 2]              ; escrever pernaD
                MOV M[IO_escrever], R1              

                POP R1
                RET

NOP1:           NOP 
                RTI 

GoodGorilaSpot: PUSH R1 
                PUSH R2 
                
                MOV R1, M[G1_StartPoint]    ; R1 vai lidar com Y             
                
                SHR R1, 8 
                MOV R2, 0005h                  ; Y acima de 0500h 
                CMP R2, R1 
             ;   JMP.P   gerar novo numero
                
                MOV R2, 0015h   
                CMP R2, R1                     ;Y abaixo de 1500h 
              ;  JMP.N   gerar novo numero
                
                MOV R1, M[G1_StartPoint]    ; R1 vai lidar com X 
                
                SHL R1, 8 
                SHR R1, 8 
                MOV R2, 0020h                   ; X acima de 0020h
                CMP R2, R1 
             ;   JMP.P   gerar novo numero
                
                MOV R2, 0045h
                CMP R2, R1                     ; X abaixo de 0045h
             ;   JMP.N   gerar novo numero 
                
             ;   CALL print 2o gorila 
			 

;-----------------------------------------------INFORMACOES INICIAIS-----------------------------------------------------------------
                
introduzinfo:	MOV R2, cursorA
				MOV R3, info
escreveA:		MOV M[IO_controlo], R2
				MOV R4, M[R3]
				MOV M[IO_escrever], R4
				INC R2
				INC R3
				CMP R4, ' ' 
				BR.NZ escreveA
                MOV R2, cursorV
escreveV:       MOV M[IO_controlo], R2 
                MOV R4, M[R3]
                MOV M[IO_escrever], R4
                INC R2
                INC R3
                CMP R4, ' '
                BR.NZ escreveV
                MOV R2, cursorS
escreveS:       MOV M[IO_controlo], R2
                MOV R4, M[R3]
                MOV M[IO_escrever], R4
                INC R2
                INC R3
                CMP R4, ' '
                BR.NZ escreveS
                
				RET  
				
				
;------------------------------------------BOTOES-----------------------------------------------------------------------------				
                
botao1:         MOV R1, 1
                MOV M[digito], R1
                MOV M[botao], R1
                RTI
                
botao0:         MOV R1, 1
                MOV M[botao], R1
                MOV M[digito], R0
                RTI
                
botao2:         MOV R1, 1
                MOV M[botao], R1
                MOV R1, 2
                MOV M[digito], R1
                RTI
                
botao3:         MOV R1, 1
                MOV M[botao], R1
                MOV R1, 3
                MOV M[digito], R1
                RTI
                
botao4:         MOV R1, 1
                MOV M[botao], R1
                MOV R1, 4
                MOV M[digito], R1
                RTI
                
botao5:         MOV R1, 1
                MOV M[botao], R1
                MOV R1, 5
                MOV M[digito], R1
                RTI
                
botao6:         MOV R1, 1
                MOV M[botao], R1
                MOV R1, 6
                MOV M[digito], R1
                RTI
                
botao7:         MOV R1, 1
                MOV M[botao], R1
                MOV R1, 7
                MOV M[digito], R1
                RTI
                
botao8:         MOV R1, 1
                MOV M[botao], R1
                MOV R1, 8
                MOV M[digito], R1
                RTI
                
botao9:         MOV R1, 1
                MOV M[botao], R1
                MOV R1, 9
                MOV M[digito], R1
                RTI
                
                
espera_A:       MOV R1, M[botao]
                CMP R1, R0
                BR.Z espera_A
                MOV R2, M[ANG]
                MOV R3, 10
                MUL R3, R2
                MOV M[ANG], R2
                MOV R1, M[digito]
                ADD M[ANG], R1
                MOV R2, 0008h
                MOV M[IO_controlo], R2
                ADD R1, '0'
                MOV M[IO_escrever], R1
                MOV M[botao], R0
espera_A1:      MOV R1, M[botao]
                CMP R1, R0
                BR.Z espera_A1
                MOV R2, M[ANG]
                MOV R3, 10
                MUL R3, R2
                MOV M[ANG], R2
                MOV R1, M[digito]
                ADD M[ANG], R1
                MOV R2, 0009h
                MOV M[IO_controlo], R2
                ADD R1, '0'
                MOV M[IO_escrever], R1
                MOV M[botao], R0
                RET
                

espera_V:       MOV R1, M[botao]
                CMP R1, R0
                BR.Z espera_V
                MOV R2, M[VEL]
                MOV R3, 10
                MUL R3, R2
                MOV M[VEL], R2
                MOV R1, M[digito]
                ADD M[VEL], R1
                MOV R2, 010Ch
                MOV M[IO_controlo], R2
                ADD R1, '0'
                MOV M[IO_escrever], R1
                MOV M[botao], R0
espera_V1:      MOV R1, M[botao]
                CMP R1, R0
                BR.Z espera_V1
                MOV R2, M[VEL]
                MOV R3, 10
                MUL R3, R2
                MOV M[VEL], R2
                MOV R1, M[digito]
                ADD M[VEL], R1
                MOV R2, 010Dh
                MOV M[IO_controlo], R2
                ADD R1, '0'
                MOV M[IO_escrever], R1
                RET
                
