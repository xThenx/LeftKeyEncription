                                                                                                   include 'emu8086.inc'

org 100h

;/////////////////////////////////////////////////////////////////
MPRINTTEXT macro TextToPrint
    mov ah, 9 
    mov dx, offset TextToPrint 
    int 21h 
ENDM
;/////////////////////////////////////////////////////////////////

;/////////////////////////////////////////////////////////////////
;///////////////READING TEXT UNIVERSAL////////////////////////////
;/////////////////////////////////////////////////////////////////
MREADINGTEXT MACRO TextToFill
    
    ReadCharacter:
        ;Preparamos el poder de la lectura
        mov ah, 1
        int 21h
        
        ;Sera un Enter?
        cmp al, 13
        jz FinishReader
        
        ;Quiere borrar Texto?
        ;cmp al, 8
        cmp al, 8
        jz BackDelete
        
        ;Continuar normal
        sub al, 32
        mov TextToFill[si], al
        inc si
        jmp ReadCharacter  
        
    BackDelete:
        dec si
        mov TextToFill[si], '$'
        jmp ReadCharacter  
        
    FinishReader:
    ;This is only to finish the macro
       
    
ENDM
;/////////////////////////////////////////////////////////////////



;/////////////////////////////////////////////////////////////////
;/////////////START THE PROGRAM///////////////////////////////////
;/////////////////////////////////////////////////////////////////

StartProgram:
 
CALL PPRINTHEADER       

MAINMENU: 
  
mov ah, 1                              ;0=48 / 1=49 / 2=50 Encriptar cadena de texto / 3=51 /   
int 21h 

;LEYENDO TECLADO

cmp al, 48
jz VOID_ENCRIPTAR

cmp al, 49
jz VOID_DESENCRIPTAR

;Opcion 2 Encriptar cadena de texto
;cmp al, 50 
;jz VOID_ENCRIPTAR
 

;jmp error5
;cmp al, 51
;jz salir del programa

















;/////////////////////////////////////////////////////////////////
;///////////////////FINISH THE START PROGRAM//////////////////////
;/////////////////////////////////////////////////////////////////










;/////////////////////////////////////////////////////////////////
;/////////////END THE PROGRAM/////////////////////////////////////
;/////////////////////////////////////////////////////////////////
EndProgram:
RET
;/////////////////////////////////////////////////////////////////
;/////////////END THE PROGRAM/////////////////////////////////////
;/////////////////////////////////////////////////////////////////


;/////////////////////////////////////////////////////////////////
PPRINTHEADER PROC
    MOV AH,00H ;FUNCION PARA LIMPIAR PANTALLA
    MOV AL,03H ;MODO TEXTO 80X25
    INT 10H
    
    MPRINTTEXT varline1
    MPRINTTEXT salto
    MPRINTTEXT titulo
    MPRINTTEXT salto
    MPRINTTEXT varline1
    
    MPRINTTEXT salto
    MPRINTTEXT varline1
    MPRINTTEXT salto
    MPRINTTEXT msgdescrip
    MPRINTTEXT salto
    MPRINTTEXT msgver
    MPRINTTEXT salto 
    
    MPRINTTEXT varline2
    MPRINTTEXT msg1
    MPRINTTEXT msg2
    MPRINTTEXT msg3
    MPRINTTEXT msg4
    MPRINTTEXT msg5
    MPRINTTEXT salto
    jmp MAINMENU
        
PPRINTHEADER ENDP
;/////////////////////////////////////////////////////////////////

;/////////////////////////////////////////////////////////////////
;/////////////////ENCRIPT METHOD//////////////////////////////////
;/////////////////////////////////////////////////////////////////
VOID_ENCRIPTAR:
    MOV contadorllave,0
    MOV llave, 0
    MPRINTTEXT salto
    MPRINTTEXT msgllave ;Escriba una palabra que se utilizara como llave para encriptar su texto
    MPRINTTEXT salto
    
    ReadCharacter:
        ;Preparamos el poder de la lectura
        mov ah, 1
        int 21h
        
        ;Sera un Enter?
        cmp al, 13
        jz FinishReader
        
        ;Quiere borrar Texto?
        ;cmp al, 8
        cmp al, 8
        jz BackDelete
        
        ;Continuar normal
        sub al, 32
        mov llave[si], al
        inc si
        inc contadorllave ; Tambien le sumamos al contador
        jmp ReadCharacter
    BackDelete:
        dec si
        mov llave[si], '$'
        jmp ReadCharacter  
    
    FinishReader:
    
    
        
;---END TO READ, NOW LETS OPEN THE FILE TO ENCRIPT
    
crear: 
    mov ah, 3Ch ;create or truncate file 
    mov cx, 0 ;;  normal - no attributes
    mov dx, offset fileout 
    int 21h 
    jc error3 
    mov handler2, ax     
    
OpenFile: 
    mov ah, 3dh 
    mov al, 2 
    mov dx, offset filein 
    int 21h 
    ;jc error1 
    mov handler, ax  
      
ReadFile: 
    mov bx, handler 
    mov ah, 3fh 
    mov cx, 10 
    mov dx, offset fragmento 
    int 21h   
    ;jc error2          
    cmp ax, 0 ;? EOF 
    jz CloseFile              

WriteTheEncryption: 
    call EncryptProcedure  ;este deberia ser procedure2 porque el 1 es el que se tiene que sumar la llave
    call ConcatProcedure
    call EncryptProcedure3
    xor si,si 
    mov ah, 40h 
    mov bx, handler2 
    mov cx, num_caracteres  ; Number of bytes
    ;MPRINTTEXT copiaFragmento
    mov dx, offset CopiaFragmento 
    int 21h 
    jc error4 
   
    
Clean: 
    ;;limpiar varible 
    mov si, offset limpio 
    mov di, offset fragmento 
    mov cx, 10 
    rep movsb     
         
    
CloseFile: 
    ;cerrar archivo 
    mov ah, 3eh 
    mov bx, handler 
    int 21h 
     
    mov bx, handler2 
    int 21h




VOID_DESENCRIPTAR:
    MOV contadorllave,0
    MOV llave, 0
    MPRINTTEXT salto
    MPRINTTEXT msgllave ;Hay que cambiar esto para desencriptar
    MPRINTTEXT salto
    
    ReadCharacter2:
        ;Preparamos el poder de la lectura
        mov ah, 1
        int 21h
        
        ;Sera un Enter?
        cmp al, 13
        jz FinishReader2
        
        ;Quiere borrar Texto?
        ;cmp al, 8
        cmp al, 8
        jz BackDelete2
        
        ;Continuar normal
        sub al, 32
        mov llave[si], al
        inc si
        inc contadorllave ; Tambien le sumamos al contador
        jmp ReadCharacter2
    BackDelete2:
        dec si
        mov llave[si], '$'
        jmp ReadCharacter2  
    
    FinishReader2:
    

    crear2: 
        mov ah, 3Ch ;create or truncate file 
        mov cx, 0 ;;  normal - no attributes
        mov dx, offset fileout 
        int 21h             
        jc error3 
        mov handler2, ax     
    
OpenFile2: 
    mov ah, 3dh 
    mov al, 2 
    mov dx, offset filein 
    int 21h 
    ;jc error1 
    mov handler, ax  
      
ReadFile2: 
    mov bx, handler 
    mov ah, 3fh 
    mov cx, 10 
    mov dx, offset fragmento 
    int 21h   
    ;jc error2          
    cmp ax, 0 ;? EOF 
    jz CloseFile              

WriteTheEncryption2: 
    call DecryptProcedure3
    call DeConcatProcedure
    call DecryptProcedure 
    
    
    xor si,si 
    mov ah, 40h 
    mov bx, handler2 
    mov cx, num_caracteres  ; Number of bytes
    ;MPRINTTEXT copiaFragmento
    mov dx, offset CopiaFragmento 
    int 21h 
    jc error4 
   
    
Clean2: 
    ;;limpiar varible 
    mov si, offset limpio 
    mov di, offset fragmento 
    mov cx, 10 
    rep movsb     
         
    
CloseFile2: 
    ;cerrar archivo 
    mov ah, 3eh 
    mov bx, handler 
    int 21h 
     
    mov bx, handler2 
    int 21h

    
         

;---WELL, NOW GO TO MAINMENU AGAIN
jmp MAINMENU
 
;/////////////////////////////////////////////////////////////////
;////////////////////END OF ENCRIPT METHOD////////////////////////
;/////////////////////////////////////////////////////////////////


DecryptProcedure PROC 
    ;Make the count  
    ;Sumando 2 a su codigo ASCI 
    mov si, 0
    mov cx, num_caracteres  
    hacer5:
       mov al,copiaFragmento[si]  
       dec al
       dec al
       mov copiaFragmento[si],al   
       inc si 
    loop hacer5
    ;MPRINTTEXT copiaFragmento
    mov ah, 1
    int 21h 
       
    ret
          
DecryptProcedure ENDP




DeConcatProcedure PROC
    
    mov ah, 1
    int 21h 
    mov cx, contadorllave
    mov bx, 0 
    mov si, num_caracteres
    dec si
    
    hacer2:
        mov al, llave[bx]
        cmp al, copiaFragmento[si]
        ;jne llaveIncorrecta
        
        mov copiaFragmento[si], 0       
        mov bl, copiaFragmento[si]
        ;push fragmento[si], al
        dec num_caracteres
        dec si
        inc bx
    
    loop hacer2
    ;MPRINTTEXT copiaFragmento
    mov ah, 1
    int 21h 
    
    
    ret
    
DeConcatProcedure ENDP



DecryptProcedure3 PROC     
    
    
    
    mov cx, 10 
    mov al, 10
    mov si, 0 
    
    contador5: 
        mov al, fragmento[si] 
        cmp al,0 
        je salidacontador
        inc si  
    loop contador5
   
  salidacontador: 
    mov num_caracteres, si
    mov cx, num_caracteres
    mov si, cx
    dec si
    mov al, fragmento[1]     
    mov copiaFragmento[si], al    
    dec si
    mov al, fragmento[0]
    mov copiaFragmento[si], al
    
    mov cx, si 
    mov si, 0
    mov bx, 2
    
    hacer3:
        mov al, fragmento[bx] 
        mov copiaFragmento[si], al 
        ;MPRINTTEXT copiaFragmento
        ;MPRINTTEXT salto
        inc si
        inc bx
        inc dx 
    
    loop hacer3
    mov ah, 1
    int 21h 
    ;MPRINTTEXT copiaFragmento
    ret
      
        
    
DecryptProcedure3 ENDP



EncryptProcedure PROC 
    ;Make the count  
    ;Sumando 2 a su codigo ASCI 
    xor si,si  
    mov cx,10 ;cx 10 debido al limite de 10 caracteres 
    mov dx, offset fragmento  
    hacer: 
        mov al, fragmento[si] 
        cmp al,0        
        je terminar1 
        cmp al,255   
        jnge siguiente 
       
        siguiente: 
            inc al
            inc al
            mov fragmento[si],al
             
            inc si 
    loop hacer
    terminar1:
        mov num_caracteres, si  
    ;Limite de caracteres 
    ret
          
EncryptProcedure ENDP


ConcatProcedure PROC
    
    mov cx, contadorllave
    mov bx, 0 
    mov si, num_caracteres
    
    hacerResta:
        mov al, llave[bx]
        mov fragmento[si], al
        inc num_caracteres
        inc si
        inc bx
    
    loop hacerResta

    ret
    
ConcatProcedure ENDP


EncryptProcedure3 PROC     
    
    mov dx, 0 
    mov cx, num_caracteres
    mov si, cx
    dec si
    mov al, fragmento[si]     
    mov copiaFragmento[1], al
    ;MPRINTTEXT copiaFragmento
    ;MPRINTTEXT salto    
    inc dx
    dec si
    mov al, fragmento[si]
    mov copiaFragmento[0], al
    ;MPRINTTEXT copiaFragmento
    ;MPRINTTEXT salto    
    inc dx
    mov cx, si 
    mov si, 2
    mov bx, 0
    
    hacerCopia:
        mov al, fragmento[bx] 
        mov copiaFragmento[si], al 
        ;MPRINTTEXT copiaFragmento
        ;MPRINTTEXT salto
        inc si
        inc bx
        inc dx
    
    
    loop hacerCopia
    ;MPRINTTEXT copiaFragmento
    ;MPRINTTEXT salto
    ret
      
        
    
EncryptProcedure3 ENDP
                             
                             
                             
llaveincorrecta:
    jmp error1

;/////////////////////////////////////////////////////////////////                                                                  
;/////////////////////ERROR///////////////////////////////////////    
;/////////////////////////////////////////////////////////////////
error1: 
    MPRINTTEXT msgError1 
    jmp fin 
     
error2: 
    MPRINTTEXT msgError2 
    jmp fin 
     
error3: 
    MPRINTTEXT msgError3 
    jmp fin  
 
error4: 
    MPRINTTEXT msgError4 
    jmp fin 

fin: 

error5:
    MPRINTTEXT ErrorN1
    ;CALL PPRINTHEADER
    ;jmp MAINMENU 
    jmp EndProgram

ret                                                                      
;/////////////////////////////////////////////////////////////////                                                                  
;/////////////////////STUFF///////////////////////////////////////    
;/////////////////////////////////////////////////////////////////
 
        
msgError1 db 10,13,'Error: No se pudo abrir el archivo. $' 
msgError2 db 10,13,'Error: Al leer los caracteres$' 
msgError3 db 10,13,'Error: No se puede crear el archivo. $' 
msgError4 db 10,13,'Error: No se puede escribir el archivo. $'

  
;variables de usos varios 

varline1 dw 254,254,254,254,254,254,254,254,254,254,254,254, '$'
varline2 dw 177,177,177,177,177,177,177,177,177,177,177,177, '$'
salto db 10,13,'$'

;variables de titulo
msgver db '(Version < 1) $'
msgdescrip db 'Encriptador y desencriptador de texto $'
titulo db '        LeftKey$' 

;variables de entrada de texto

msg1 db 10,13,'Elegir opcion a ejecutar: $'       
msg2 db 10,13,'Presione la tecla 0 para encriptar un archivo. $'
msg3 db 10,13,'Presione la tecla 1 para desencriptar un archivo. $'
msg4 db 10,13,'Presione la tecla 2 para encriptar una cadena de texto. $'
msg5 db 10,13,'Presione la tecla 3 para salir del programa. $'           
msgllave db 10,13,'Escriba una palabra que se utilizara como llave para encriptar su texto: $'

ErrorN1 db 10,13,'Esa opcion no es posible :( $'

;variable para guardado de texto
llave db 20 dup('$')
contadorllave dw 0 

frase db 20 dup('$')
bytes db 0

handler dw ?  
handler2 dw ?
filein db 'C:\prueba\ToEncript.txt',0
fileout db 'C:\prueba\EncriptedFile.txt',0 
fragmento db '$$$$$$$$$$$$$$$$$$$$$$$',0 
limpio db '                     ',0 

num_caracteres dw 0 
copiaFragmento db '',0 
