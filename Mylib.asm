;macro pentru deschiderea unui fisier
open_file macro filename, mode

	;apelam fopen
	push offset mode
	push offset filename
	call fopen
	add esp, 8
	
endm

;macro pentru inchiderea unui fisier
close_file macro

	;apelam fclose
	call fclose
	add esp, 4
	
endm

;macro pentru functia list
list macro 

	local print_loop
	
	lea esi, text ;incarcam in esi adresa de inceput a varibilei 'text'
	
	print_loop:
	
		;incarcam pe stiva parametrii de la printf
		push [esi]
		push offset char_format
		call printf
		add esp, 8
		
		inc esi
		
		cmp byte ptr[esi], 0 ;alocand un spatiu mai mare pentru textul din fisier, cand se va gasi un 0 in memorie bucla se va opri
		
	jne print_loop
	
endm

;macro pentru citirea textului din fisier in variabila 'text'
read_file macro

	local read_loop
	local close_f

	open_file source_file, r_mode ;apelam macroul pentru deschiderea fisierului
	mov edi, eax ;salvam pointer-ul la fisier in EDI
	
	lea esi, text ;incarcam in esi adresa de inceput a variabilei 'text'
	
	;punem pe stiva parametrii pentru fscanf
	push offset buffer
	push offset char_format
	push edi ;stream

	read_loop:
	
		call fscanf
		test eax, eax
		js close_f ;daca se ajunge la sfarsitul documentului se sare la inchiderea fisierului
		xor eax, eax ;facem eax sa fie 0
		mov al, buffer 
		
		;memoram in variabila 'text' tot textul din fisier
		mov [esi], al  
		inc esi
		
		jmp read_loop
		
	close_f:
		
		add esp, 12 ;curatam stiva de la fscanf
		push edi ;stream
		close_file ;apelam macroul pentru inchiderea fisierului
		
endm

;macro pentru functia toLower
toLower macro
	
	local lower_loop
	local lower_jump
	
	lea esi, text ;incarcam in esi adresa de inceput a variabilei 'text'
	
	lower_loop: 
	
		;in cazul in care caracterul are codul ASCII intre 65 si 90 inseamna ca este litera mare
		;si este nevoie sa adunam 32 decimal pentru a-l transforma in litera mica
		cmp byte ptr[esi], 65
		jnge lower_jump
		cmp byte ptr[esi], 90
		jnbe lower_jump
		add byte ptr[esi], 32
		lower_jump:
		
		inc esi

		cmp byte ptr[esi], 0 ;alocand un spatiu mai mare pentru textul din fisier, cand se va gasi un 0 in memorie bucla se va opri
		
		jne lower_loop
		
		write_file source_file ;rescriem in fisier textul formatat
	
endm

;macro pentru functia toUpper
toUpper macro
	
	local lower_loop
	local upper_jump
	
	lea esi, text ;incarcam in esi adresa de inceput a variabilei 'text'
	
	lower_loop: 
	
		;in cazul in care caracterul are codul ASCII intre 97 si 122 inseamna ca este litera mica
		;si este nevoie sa scadem 32 pentru a-l transforma in litera mare
		cmp byte ptr[esi], 97
		jnge upper_jump
		cmp byte ptr[esi], 122
		jnbe upper_jump
		sub byte ptr[esi], 32
		upper_jump:
		
		inc esi

		cmp byte ptr[esi], 0 ;alocand un spatiu mai mare pentru textul din fisier, cand se va gasi un 0 in memorie bucla se va opri
		
	jne lower_loop
		
		write_file source_file ;rescriem in fisier textul formatat
	
endm

;macro pentru scrierea in fisier
write_file macro source_file

	local print_loop
	
	lea esi, text

	open_file source_file, w_mode
	mov edi, eax
	
	print_loop:
	
		;punem pe stiva parametrii pentru functia fprintf
		push [esi]
		push offset char_format
		push edi ;stream
		call fprintf
		add esp, 12
		
		inc esi
		
		cmp byte ptr[esi], 0 ;alocand un spatiu mai mare pentru textul din fisier, cand se va gasi un 0 in memorie bucla se va opri
		
		jne print_loop
		
	push edi ;stream
	close_file ;apelam macroul pentru inchiderea fisierului
	
endm

;macro pentru functia toSentence
toSentence macro

	local sentence_loop
	local upper_jump
	local continue

	toLower ;apelam macrou-ul toLower pentru a face toate litere mici
	
	lea esi, text ;incarcam in esi adresa de inceput a varibilei 'text'
	
	;daca primul caracter din text este litera mica o transformam in litera mare
	cmp byte ptr[esi], 97
	jnge upper_jump
	cmp byte ptr[esi], 122
	jnbe upper_jump
	sub byte ptr[esi], 32
	
	sentence_loop:
		
		;verificam daca caracterul este "." (punct)
		cmp byte ptr[esi], 46
		jne continue
		
		;daca se gaseste un punct, consideram ca avem un spatiu dupa el, iar in cazul in care caracterul de dupa
		;spatiu este litera mica o transformam in litera mare
		cmp byte ptr[esi + 2], 97
		jnge upper_jump
		cmp byte ptr[esi + 2], 122
		jnbe upper_jump
		sub byte ptr[esi + 2], 32
		upper_jump:
		
		continue:
		inc esi
		cmp byte ptr[esi], 0 ;alocand un spatiu mai mare pentru textul din fisier, cand se va gasi un 0 in memorie bucla se va opri
		
		jne sentence_loop
	
	write_file source_file ;rescriem in fisier textul formatat
	
endm

findc macro c

	local findc_loop
	local counter

	mov edi, 0 ;folosim registrul edi pentru a calcula numarul de aparitii al caracterului dorit
	lea esi, text ;incarcam in esi adresa de inceput a varibilei 'text'
	
	mov ebx, 1 ;folosim registrul ebx pentru a afla indexul la care apare caracterul cautat
	
	push c
	push offset index_msg
	call printf
	add esp, 8
	
	findc_loop:
	
		cmp byte ptr[esi], c
		jne counter
		inc edi
		
		;afiseaza indexul la care apare caracterul
		push ebx
		push offset int_format
		call printf
		add esp, 8
		counter:
		
		inc ebx
		inc esi
		
		cmp byte ptr[esi], 0 ;alocand un spatiu mai mare pentru textul din fisier, cand se va gasi un 0 in memorie bucla se va opri
		
		jne findc_loop
	
	;punem pe stiva parametrii pentru functia printf
	push edi
	push offset findc_msg
	call printf
	add esp, 8
	
endm
		
find macro wrd

	local find_loop
	local continue
	local counter

	strlen wrd, lg_wrd ;memoram in lg_wrd lungimea secventei de caractere pe care dorim sa o determinam
	lea esi, text ;incarcam in esi adresa textului citit din fisier
	lea edi, wrd ;incarcam in edi adresa secventei de caractere a carui numar de aparitii dorim sa o determinam
	mov ebx, 0 ;initializam registrul ebx
	
	find_loop:
		mov al, byte ptr[edi] ;mutam in al, pe rand, fiecare caracter din secventa de caractere
		cmp byte ptr[esi], al ;comparam caracterele din secventa de caractere cu cele din text
		jne counter
		inc bl ;cand se gaseste potrivire de caracter se incrementeaza bl
		inc edi 
		cmp bl, lg_wrd ;daca bl = lungimea_secventei_de_caractere inseamna ca secventa de caractere a fost gasita
		jne continue
		inc bh ;memoram in bh numarul de aparitii al secventei de caractere
		;daca se gaseste potrivire reinitializam bl la 0 si reincarcam in edi adresa secventei de caractere
		mov bl, 0 
		lea edi, wrd
		continue:
		counter:
		inc esi
		cmp byte ptr[esi], 0 ;cand se ajunge la sfarsitul textului citit din fisier bucla se opreste
		jne find_loop
		
	;mutam din bh (numarul de aparitii a secventei de caractere) in eax pentru a-l putea afisa
	mov eax, 0 
	mov al, bh
	push eax
	push offset wordd
	push offset find_msg
	call printf
	add esp, 12
		
endm


;macro care returneaza lungimea unui sir de caractere
strlen macro string, len

	local strlen_loop

	;putem in esi adresa string-ului a carui lungime dorim sa o determinam
	lea esi, string
	mov bl, 0 ;folosim registrul bl pentru a calcula lungimea sirului
	
	strlen_loop:
		inc esi
		inc bl
		cmp byte ptr[esi], 0 ;cand se ajunge la un caracter null se opreste incrementarea registrelor esi si bl si se obtine lungimea sirului
		jne strlen_loop
		
	lea esi, len ;incarcam in esi adresa in care dorim sa retinem lungimea sirului
	mov [esi], bl ;mutam la adresa respectiva lungimea sirului
		
endm