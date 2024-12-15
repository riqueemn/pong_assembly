STACK SEGMENT PARA STACK
    DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'

    WINDOW_WIDTH DW 140h ;320 pixels
    WINDOW_HEIGHT DW 0C8h ;200 pixels
    WINDOW_BOUNDS DW 6 ;variable used to check collisions early

    TIME_AUX DB 0 ;Variável utilzada para checar o tempo de alteração
    BALL_X DW 0Ah ;Posição X (coluna) da bola
    BALL_Y DW 0Ah ;Posição Y (linha) da bola
    BALL_SIZE DW 04h ;tamanho da bola (how many pixels does the ball have in width and height)
    BALL_VELOCITY_X DW 05h ;X (horizontal) velocity of the ball
    BALL_VELOCITY_Y DW 02h ;Y (vertical) velocity of the ball

DATA ENDS

CODE SEGMENT PARA 'CODE'

    MAIN PROC FAR
    ASSUME CS:CODE, DS:DATA, SS:STACK   ;assume as code, data and stack segments the respective registers
    PUSH DS                             ;push to the stack the DS segment
    SUB AX, AX                          ;limpar o registrador AX
    PUSH AX                             ;push AX to the stack
    MOV AX,DATA                         ;salvar no registrador AX o conteúdo de DATA segment
    MOV DS,AX                           ;salvar no DS segment o conteúdo de AX
    POP AX                              ;realease the top item from the stack to the AX register
    POP AX                              ;realease the top item from the stack to the AX register

        MOV AH, 00h ;set the configuration to video mode
        MOV AL, 13h ;choose the video mode
        INT 10h     ;execute the configuration

        MOV AH,0Bh ;set the configuration
        MOV BH,00h ;to the background color
        MOV BL, 00h ;choose black as background color
        INT 10h    ;execute the configuration

        CALL CLEAR_SCREEN

        CHECK_TIME: 
            MOV AH, 2Ch ;Captura o tempo do sistema
            INT 21h ;CH = hour CL = minute DH = second DL = 1/100 seconds

            CMP DL,TIME_AUX ;is the current time equal to the previous one(TIME_AUX)?
            JE CHECK_TIME ;Se é igual, cheque novamente

            ;Se é diferente, então desenhe, mova, etc.
            MOV TIME_AUX, DL ;Atualize o tempo

            CALL CLEAR_SCREEN
            CALL MOVE_BALL
            CALL DRAW_BALL

            JMP CHECK_TIME ;After everything check time again

        RET
    MAIN ENDP

    MOVE_BALL PROC NEAR
        MOV AX, BALL_VELOCITY_X
        ADD BALL_X, AX ;move the ball horizontally

        MOV AX, WINDOW_BOUNDS
        CMP BALL_X, AX
        JL NEG_VELOCITY_X ;BALL_X < 0 + WINDOW_BOUNDS(Y -> collided)

        MOV AX, WINDOW_WIDTH
        SUB AX, BALL_SIZE
        SUB AX, WINDOW_BOUNDS
        CMP BALL_X, AX ;BALL_X > WINDOW_WIDTH - BALL_SIZE - WINDOW_BOUNDS (Y -> collided)
        JG NEG_VELOCITY_X

        MOV AX, BALL_VELOCITY_Y
        ADD BALL_Y, AX ;move the ball vertically

        MOV AX, WINDOW_BOUNDS
        CMP BALL_Y, AX ;BALL_Y < 0 + WINDOW_BOUNDS (Y -> collided)
        JL NEG_VELOCITY_Y 

        MOV AX, WINDOW_HEIGHT
        SUB AX, BALL_SIZE
        SUB AX, WINDOW_BOUNDS
        CMP BALL_Y, AX
        JG NEG_VELOCITY_Y ;BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS (Y -> collided)

        RET

        NEG_VELOCITY_X:
            NEG BALL_VELOCITY_X ;BALL_VELOCITY_X = - BALL_VELOCITY_X
            RET

        NEG_VELOCITY_Y:
            NEG BALL_VELOCITY_Y ;BALL_VELOCITY_Y = - BALL_VELOCITY_Y
            RET

    MOVE_BALL ENDP

    DRAW_BALL PROC NEAR

        MOV CX, BALL_X ;Seta o valor inicial da coluna (X)
        MOV DX, BALL_Y ;Seta o valor inicial da linha (Y)

        DRAW_BALL_HORIZONTAL:
            MOV AH, 0Ch ;Setar a configuração para escrever um pixel
            MOV AL, 0Fh ;Escolhe a cor
            MOV BH, 00h ;Seta o número de páginas
            INT 10h     ;Executa a configuração
            INC CX      ;CX = CX + 1
            MOV AX, CX  ;CX - BALL_X > BALL_SIZE (Y -> Nós vamos para próxima linha, N -> Nós vamos para próxima coluna)
            SUB AX, BALL_X
            CMP AX, BALL_SIZE
            JNG DRAW_BALL_HORIZONTAL
            MOV CX, BALL_X ;O registrador CX volta para a coluna inicial
            INC DX         ;Nós avançamos uma linha
            MOV AX, DX     ;DX - BALL_Y > BALL_SIZE (Y -> Nós saimos desse procedimento, N -> Nós continuamos para a próxima linha)
            SUB AX, BALL_Y
            CMP AX, BALL_SIZE
            JNG DRAW_BALL_HORIZONTAL

        RET
    DRAW_BALL ENDP

    CLEAR_SCREEN PROC NEAR
        MOV AH, 00h ;set the configuration to video mode
        MOV AL, 13h ;choose the video mode
        INT 10h     ;execute the configuration

        MOV AH,0Bh ;set the configuration
        MOV BH,00h ;to the background color
        MOV BL, 00h ;choose black as background color
        INT 10h    ;execute the configuration

        RET
    CLEAR_SCREEN ENDP

CODE ENDS
END