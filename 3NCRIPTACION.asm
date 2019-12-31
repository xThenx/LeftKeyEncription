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
jz VOID_ENCRIPTAR


cmp al, 51
ret

jmp StartProgram
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
    mov num_Opcion, al ; Guardamos Opcion
    
    
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
        
        
        mov llave[si], al
        inc si
        inc contadorllave ; Tambien le sumamos al contador
        jmp ReadCharacter
    BackDelete:
        dec si
        dec contadorllave ; Restamos al contador de la llave
        mov llave[si], '$'
        jmp ReadCharacter  
    
    FinishReader:
    ;Se termino de escribir la llave, sigamos
    
        
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
    mov cx, 200 
    mov dx, offset fragmento 
    int 21h   
    jc error2          
    cmp ax, 0 ;? EOF 
    jz CloseFile 
    
    

WriteTheEncryption:

    cmp num_Opcion, 48
    jz PEncryp
    
    cmp num_Opcion, 49
    jz DEncryp
    
    PEncryp: 
    call PEncryptation  ;
    jmp ContinuarCryp
    
    DEncryp:
    call PDencryptation  ;
    jmp ContinuarCryp
    
    ContinuarCryp:
    xor si,si 
    mov ah, 40h 
    mov bx, handler2 
    mov cx, num_caracteres  ; Number of bytes
    ;MPRINTTEXT copiaFragmento 
    
    cmp num_Opcion, 48
    jz VarEncriptar
    
    cmp num_Opcion, 49
    jz VarDecriptar
    
     VarEncriptar:
     mov dx, offset TextToEncrypt2 ; En esta variable se queda cuando encriptamos
     jmp ContinuarWork 
     
     VarDecriptar:
     mov dx, offset TextToEncrypt3 ; En esta variable se queda cuando desencriptamos 
     jmp ContinuarWork
     
    ContinuarWork: 
    int 21h 
    jc error4 
   
    
Clean: 
    ;;limpiar varible 
    mov si, offset limpio 
    mov di, offset TextToEncrypt 
    mov cx, 100 
    rep movsb     
         
    
CloseFile: 
    ;cerrar archivo 
    jmp StartProgram
    mov ah, 3eh 
    mov bx, handler 
    int 21h 
     
    mov bx, handler2 
    int 21h
    
    jmp StartProgram



 
;/////////////////////////////////////////////////////////////////
;////////////////////END OF ENCRIPT METHOD////////////////////////
;/////////////////////////////////////////////////////////////////
PEncryptation PROC

xor si,si


;mov cx, contadorllave ;obtenemos el valor del contador
;inc cx                ;le sumamos uno para la posicion si

concat:

cmp si, contadorllave
je finalizarconcat1

mov al, llave[si]

mov TextToEncrypt[si],al

inc si
jmp concat

finalizarconcat1:

;xor si,si
xor di,di
mov di, contadorllave ;obtenemos el valor del contador


concat2:
;Make the count
;Sumando 2 a su codigo ASCI
xor si,si
xor dx,dx
;mov cx,10 ;cx 10 debido al limite de 10 caracteres

mov dx, offset fragmento
hacer:
mov al, fragmento[si]    ;Guardamos caracter en al
;cmp al,0
;je terminar

cmp al, 248
je terminar1    ;Ya no hay nada que leer

incrementar:       ;Sumemos y sigamos en el loop
mov TextToEncrypt[di],al
inc di
inc si
jmp hacer
; CONCATENACION REALIZADA


;loop hacer       ;No necesario a la linea je terminar1
terminar1:
add si, contadorllave
mov num_caracteres, si

;Limite de caracteres

;Ahora toca mover a la derecha uno

xor si,si
xor di,di
;mov dx, offset TextToEncrypt

PERMUTACION:
mov al, TextToEncrypt[si] ;El primero

inc si
inc di

cmp si,num_caracteres
je MoverAlPrimero 

MoverUnaPosicion:
mov TextToEncrypt2[di], al
jmp IncrementarPunteros

IncrementarPunteros:


jmp PERMUTACION

MoverAlPrimero:
xor di,di
      
mov TextToEncrypt2[di], al
jmp FinPermutacion

FinPermutacion:    


SUMASCI:
xor si,si

mov dx, offset TextToEncrypt2
 
    evaluarsumasci: 
        mov al, TextToEncrypt2[si]    ;Guardamos caracter en al
        ;cmp al,0        
        ;je terminar1
        
        cmp al, 248
        je endStepSumAsci    ;Ya no hay nada que leer
        
        ;cmp al,255               ;Comparamos el valor ASCI
        ;jnge siguiente           ;JNGE verifica si el valor es menor 
        
        cmp al, 255
        je endsumasci
        
        cmp al, 254
        je endsumasci
        
        sumaasci: 
            inc al       ;Sumamos una posicion al ASCI
            inc al       ;Sumamos una posicion al ASCI
            
             
        endsumasci:       ;Sumemos y sigamos en el loop
            mov TextToEncrypt2[si],al
            inc si 
        jmp evaluarsumasci
        
        
        
    ;loop hacer       ;No necesario a la linea je terminar1
    endStepSumAsci:


ret

ENDP

;================================================================   
;================================================================   
;================================================================   


PDencryptation PROC 
     
    
;================================================================    

RESTAASCI:
xor si,si

mov dx, offset fragmento
 
    Devaluarsumasci: 
        mov al, fragmento[si]    ;Guardamos caracter en al
        ;cmp al,0        
        ;je terminar1
        
        cmp al, 248
        je ENDRESTAASCI    ;Ya no hay nada que leer
        
        ;cmp al,255               ;Comparamos el valor ASCI
        ;jnge siguiente           ;JNGE verifica si el valor es menor 
        
        cmp al, 255
        je Dendsumasci
        
        cmp al, 254
        je Dendsumasci
        
        Dsumaasci: 
            dec al       ;Sumamos una posicion al ASCI
            dec al       ;Sumamos una posicion al ASCI
            
             
        Dendsumasci:       ;Sumemos y sigamos en el loop
            mov fragmento[si],al
            inc si
            inc num_caracteres 
        jmp Devaluarsumasci
        ;AGREGAR CONTADOR PARA NUM_CARACTERES
        
        
    ;loop hacer       ;No necesario a la linea je terminar1
    ENDRESTAASCI:


 ;================================================================

    ;===============STEP 2===========================================

;================================================================
;Ahora toca mover a la derecha uno


;mov dx, offset TextToEncrypt
xor si,si
xor di,di


DPERMUTACION:



mov al, fragmento[si] 

cmp si,0
je DMoverAlFinal 

cmp si,num_caracteres
je DFinPermutacion 
 
 
DMoverUnaPosicion:
mov TextToEncrypt[di], al
DIncrementarPunteros:

inc di
inc si

jmp DPERMUTACION
 
 
 
DMoverAlFinal:
mov di, num_caracteres
dec di     
mov TextToEncrypt[di], al
xor di, di
;inc di
inc si
jmp DPERMUTACION

DFinPermutacion:    

 

xor si,si
 ; ========================================= VALIDAR KEY
mov cx, contadorllave
Validarkey:
mov al, TextToEncrypt[si]

cmp cx, 0
je  FinalizarValidarkey

cmp llave[si], al
je nextK
jmp IncorrectKey

nextK:
inc si  
dec cx
jmp Validarkey

IncorrectKey: 
    mov si, offset limpio 
    mov di, offset TextToEncrypt 
    mov cx, 200 
    rep movsb
FinalizarValidarkey:
                  
xor si, si          
xor di, di
mov di, contadorllave 

mov ax, num_caracteres
mov num_caracteresDes, ax
xor ax,ax
mov ax, contadorllave
sub num_caracteresDes, ax
sub num_caracteres, ax ;Esto queda sucio pero, ya no hare mas lineas arriba comprobando la opcion del usuario. 
;Como entregaremos menos caracteres, tenemos que setear nuestra variable restando los de la llave


; ==================DETENIENDO 

LimpiarEntrega:                  
        
 
          
mov al, TextToEncrypt[di]

cmp si,num_caracteresDes
je FinLimpiarEntrega

mov TextToEncrypt3[si],al
inc di
inc si
jmp LimpiarEntrega
                     
FinLimpiarEntrega:
                     
Dfinalizarconcat1:
xor si,si
;mov cx, contadorllave ;obtenemos el valor del contador
;inc cx                ;le sumamos uno para la posicion si

;Dconcat:

;cmp si, contadorllave
;je Dfinalizarconcat1

;mov al, 032

;mov TextToEncrypt[si],al

;inc si
;jmp Dconcat


;xor si,si
 
;;xor di,di
;;mov di, contadorllave ;obtenemos el valor del contador


;;Dconcat2:
;Make the count
;Sumando 2 a su codigo ASCI
;;xor si,si
;;xor dx,dx
;mov cx,10 ;cx 10 debido al limite de 10 caracteres

;;mov dx, offset fragmento
;;Dhacer:
;;mov al, fragmento[si]    ;Guardamos caracter en al
;cmp al,0
;je terminar

;;cmp al, 248
;;je Dterminar1    ;Ya no hay nada que leer

;;Dincrementar:       ;Sumemos y sigamos en el loop
;;mov TextToEncrypt[di],al
;;inc di
;;inc si
;;jmp Dhacer
; CONCATENACION REALIZADA


;loop hacer       ;No necesario a la linea je terminar1
;;Dterminar1:
;;add si, contadorllave
;;mov num_caracteres, si

;Limite de caracteres






ret

ENDP



                   
                             
;llaveincorrecta:
;   jmp error1

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
;llave db 20 dup('$')
llave db 20 dup(248)
contadorllave dw 0 

frase db 20 dup('$')
bytes db 0

handler dw ?  
handler2 dw ?
filein db 'C:\Leftkey\EntradaFile.txt',0
fileout db 'C:\Leftkey\SalidaFile.txt',0 
fragmento db 248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,0
limpio db '                                                                                                                 ',0 

invalidkey db 'Contrasenia Invalida',0

num_caracteres dw 0 
copiaFragmento db '',0 

TextToEncrypt db 248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,0
TextToEncrypt2 db 248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,0
TextToEncrypt3 db 248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,0

;test

num_Opcion db 0
num_caracteresDes dw 0 