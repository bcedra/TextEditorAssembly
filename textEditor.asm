.386
.model flat, stdcall

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern fscanf: proc
extern fprintf: proc
extern fopen: proc
extern fclose: proc
extern printf: proc
extern scanf: proc

include mylib.asm

;declaram simbolul start ca public - de acolo incepe executia
public start

;sectiunile programului, date, respectiv cod
.data
optiune DD "%s",0
formatm DB "%d",0
meniu1 DB "1>list",13,10,0
meniu2 DB "2>findc",13,10,0
meniu3 DB "3>find",13,10,0
meniu4 DB "4>toLower",13,10,0
meniu5 DB "5>toUpper",13,10,0
meniu6 DB "6>toSentece",13,10,0
meniuoptiune db "operatia> ",0
meniuexit db "0>exit",10,10,0

char_format db "%c", 0
string_format db "%s", 0
int_format db "%d ", 0
new_line db " ",10,10,0

buffer db 0
text db 10000 dup(0)
caca dd 0

destination_file db "destination.txt", 0
source_file db "fisier.txt", 0
r_mode db "r", 0
w_mode db "w", 0

index_msg db "Indexul la care apare caracterul %c: ", 0
findc_msg db 13, 10, "Numar de aparitii: %d",0
find_msg db "Numar de aparitii a secventei '%s': %d", 0
new_line_msg db 13, 10, 0
msg_findc db "dati cuvantul pe care vreti sa l cautati ",0


patru db 4


wordd db "bogdan",0
wrd1 db 10 dup(0)
wrd db 10 dup(0)
wrd2 db 10 dup(0)
lg_wrd db 0
lg_wrd1 db 0

.code

start:


	read_file ;citim textul din fisier in 'text'
	push offset meniu1
	call printf
	add esp,4
	push offset meniu2
	call printf
	add esp,4
	push offset meniu3
	call printf
	add esp,4
	push offset meniu4
	call printf
	add esp,4
	push offset meniu5
	call printf
	add esp,4
	push offset meniu6
	call printf
	add esp,4
	push offset meniuexit
	call printf
	add esp,4
	
meniu:

	push offset meniuoptiune
	call printf
	add esp,4
	
	push offset optiune
	push offset formatm
	call scanf
	add esp,8
	
	
	cmp optiune,1
	je true
	jmp continuation
	true:
		list
		push offset new_line
		call printf
		add esp,4
	jmp meniu
	continuation:
	
	cmp optiune,2
	je true1
	jmp continuation1
	true1:
		findc "e"
		push offset new_line
		call printf
		add esp,4
	jmp meniu
	continuation1:
	
	cmp optiune,3
	je true2
	jmp continuation2
	true2:
		find wordd
		push offset new_line
		call printf
		add esp,4
	jmp meniu
	continuation2:
	
	cmp optiune,4
	je true3
	jmp continuation3
	true3:
		toLower
		list
		push offset new_line
		call printf
		add esp,4
	jmp meniu
	continuation3:
	
	cmp optiune,5
	je true4
	jmp continuation4
	true4:
		toUpper
		list
		push offset new_line
		call printf
		add esp,4
	jmp meniu
	continuation4:
	
	cmp optiune,6
	je true5
	jmp continuation5
	true5:
		toSentence
		list
		push offset new_line
		call printf
		add esp,4
	jmp meniu
	continuation5:

	cmp optiune,0
	je true0
	jmp meniu
	true0:
		push 0
		call exit
end start