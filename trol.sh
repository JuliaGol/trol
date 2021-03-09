#!/bin/bash
# pobiera nazwę pliku z stdin
export file=/dev/stdin
#funkcja usage pozwala na wyświetlenie pomocy
function Usage()
{
cat <<EOF

	Usage: $0  -d [ lokalizacja pliku | adres strony] -opcje 
	lub
	cat [lokalizacja pliku] | ./trol.sh -opcje
	opcje:
	-l - wypisuje liscie w pliku z drzewami
	-w - wypisuje wezły wewnetrzne
	-s - wypisuje statystyki dla wszystkich drzew w pliku,
	kolejno: liczbę liści, liczbę węzłów wewnętrznch, liczbę wszystkich węzłów
      
EOF
 
}
#funkcja pobierz pozwala na znalezieni lub pobranie i znalezienie pliku
function pobierz()
{	

	
	value=$1
	#jeżli jest taki plik to zapisuje nazwę pliku
	if [ -f $value ]; then
		export file=$value
		
	    	
	#w.p.p. pobiera plik wedug podanego adresu i zapisuje nazwe pobranego pliku

	else
		wget $value
		export file=$(basename $value)
	
			
	fi
	echo $file

}
#obsługa opcji 
while getopts "d:lwsh" opt; do
case ${opt} in
#inicjuje flagi
# pobiera plik od użytkownika
    d )  DFLG=1
#zapisuje nazwe lub adres pliku podanego w opcji 
	export filename=$OPTARG
	;;
# jeżeli opcja l to wypisuje etykiety lisci
    l ) LFLG=1
	;;
#ma wyswietlic statystyki
    s )  SFLG=1

      ;;
#kod podobny jak w "opcji l"
    w )  WFLG=1
	
      ;;
#wyswietla funkcje usag gdy uzytkownik wybierze -h
	h )  HFLG=1
      ;;
  
  esac
done
#pomoc gdy użytkownik nie podał opcji
if [ $OPTIND -eq 1 ]; then Usage ; fi
#pomoc gdy użytkownik podał tylko plik
if [  "$DFLG" = 1 ]  && [  "$LFLG" != 1 ]  && [ "$WFLG" != 1 ] && [ "$SFLG" != 1 ] && [ "$HFLG" != 1 ]; then Usage; fi
#funkcja analizuja drzew pozwala na jedno krotne "przejscie po pliku", rejestruje liście, wezly wewn. i zlicza je dla kazdego drzewa
function analiza()
{	
	export statystyki=""
	file2=$1
	#filename=$file
	#inicjujemy tablice lisci - zmienna globalna
	export tablicalisci=()
	export tablicawewn=()
	
	while read p; do 

	export tablica=( 0 0 0)
#chcemy wstawić między kolejne znaki przecinki
 	p=${p//(/(,}
	p=${p//)/,),}
	p=${p//,,/,}
	#tutaj "splitujemy" po przecinkach, w tablicy mamy elementy drzewa
	IFS=',' read -ra my_array <<< "$p"
# mamy dzie zmienne które informują czy mineliśmy nawias zamkniety czy otwarty
	export lisc=0
	export wewn=0

	for i in "${my_array[@]}"
	do
#iterujac po tablicy nadajemy odpowiedznie warości zmeinnym lisc i wewn

		if [ $i = "(" ]
			then

			lisc=1
			wewn=0
		elif [ $i = ")" ]
			then
			lisc=0
			wewn=1
			
#dodajemy do tablicy wszystkie elemety tablicy, które pojawiły sie po nawiasie otwartym a nie po zmknietym
		elif [ $lisc = 1 ] 
			then		
			let tablica[0]=${tablica[0]}+1
			if [[ !  " ${tablicalisci[@]} "  =~ " ${i} "  ]]; then
			len=${#tablicalisci[@]}
			tablicalisci[$len]=$i
			fi
			
		elif [ $wewn = 1 ] 
			then
			let tablica[1]=${tablica[1]}+1
			if [[ !  " ${tablicawewn[@]} "  =~ " ${i} "  ]]; then
			len=${#tablicawewn[@]}
			tablicawewn[$len]=$i 
			
			fi	
			
		fi



	done
	let tablica[2]="${tablica[0]}"+"${tablica[1]}"
	statystyki=" $statystyki\n${tablica[@]}"



	done < $file2

}
 
#tuaj obsługujemy kod wg nadanych flag ,tak aby opcje można było podawać dowolnie 
if [ "$DFLG" = 1 ]
then		
#pobieramy nazwe pliku za pomoca funkcji pobierz
	export file=$(pobierz $filename)
	

fi

#gdy jest podana co najmniej jedna z opcji -s -l -w to wywyłuje funkcje file
if [  "$LFLG" = 1 ] | [ "$WFLG" = 1 ] | [ "$SFLG" = 1 ]
echo
then

analiza $file
	if [ "$LFLG" = 1 ]
	then	
#wypisuje liscie

		echo "liscie: ${tablicalisci[*]}"

	fi
	if [ "$WFLG" = 1 ]
	then
#wypisuje wezly wewn
		echo "wezly wewnetrzne: ${tablicawewn[*]}"

	fi
	if [ "$SFLG" = 1 ] 
	then
#wypisuje statystyki
		echo -e $statystyki


	fi

fi
#wyswietlam pomoc
if [ "$HFLG" = 1 ] 
	then
	    Usage 

fi

exit 0

