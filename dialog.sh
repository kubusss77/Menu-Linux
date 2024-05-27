#!/bin/bash

# Konfiguracja
debug=1 #0 - tryb debugowania wyłączony, 1 - tryb debugowania włączony
debug_predkosc=1 #Czas oczekiwania po każdej informacji z trybu debugowania
menu_wymiary="27 60" #Wymiary menu (wysokość szerokość)
menu_wymiary_blad_root="7 41" #Wymiary menu błędu braku uprawnień roota



# Wyłączanie skryptu
trap 'status=1' SIGINT



# Funkcje

# Debugowanie
debug() {
    if [ $debug -eq 1 ]; then
        echo -e "$(date +%H:%M:%S) [Debug] $1"
        sleep $debug_predkosc
    fi
}



# Konwertowanie sekund na ładniejszy czas
konwertuj_czas() {
    czas=""
    if [ $1 -ge 60 ]
    then
        if [ $1 -ge 3600 ]
        then
            czas="$czas$(($1 / 3600 % 24)) godzin, "
        fi
        czas="$czas$(($1 / 60 % 60)) minut, "
    fi
    echo "$czas$(($1 % 60)) sekund"
}



# Błąd wyskakujący, kiedy wybrana została opcja potrzebująca roota
blad_brak_roota() {
    debug "Błąd: brak uprawnień roota"
    dialog --backtitle "(c) Jakub Szczepa 2024" --title "Błąd" \
        --msgbox "\n Aby $1,\n musisz uruchomić skrypt jako root." 7 41
}



# Menu główne i wszystkie jego opcje oprócz egzaminu
menu_glowne() {
    menu_glowne_wybor=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" \
        --title "Menu" \
        --menu "Wybierz co chcesz zrobić:" $menu_wymiary 1 \
        1 "Wyświetl obrazek ASCII" \
        2 "Wyświetl wszystkich użytkowników" \
        3 "Wyświetl grupy, do których należysz" \
        4 "Wyświetl zainstalowane środowiska graficzne" \
        5 "Zmień datę systemową" \
        6 "Zmień czas systemowy" \
        7 "Wyświetl konfigurację sieci" \
        8 "Zmień konfigurację sieci" \
        9 "Wyświetl od jakiego czasu system jest uruchomiony" \
        10 "Utwórz komunikat wyświetlany raz dziennie" \
        11 "Wyświetl pliki tymczasowe" \
        12 "Usuń pliki tymczasowe" \
        13 "Wyświetl ilość wolnego miejsca na dyskach" \
        14 "Wyświetl pliki o danej wielkości" \
        15 "Zmień umask" \
        16 "Zablokuj konto użytkownika" \
        17 "Zrób zrzut ekranu" \
        18 "Uruchom egzamin próbny" \
        19 "Wyloguj" \
        20 "Zamknij system" )

    debug "Wybrana opcja: $menu_glowne_wybor"

    case $menu_glowne_wybor in
        1)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Obrazek ASCII" \
                --msgbox '\n                           | 
                \n                       \       / 
                \n                         .-"-.
                \n                    --  /     \  -- 
                \n    ~~^~^~^~^~^~^~^~^~^-=======-~^~^~^~~^~^~^~^~^~^~~
                \n    ~^_~^~^~-~^_~^~^_~-=========- -~^~^~^-~^~^_~^~^~~
                \n    ~^~-~~^~^~-^~^_~^~~ -=====- ~^~^~-~^~_~^~^~~^~-^~
                \n    ~^~^~-~^~~^~-~^~~-~^~^~-~^~~^-~^~^~^-~^~^~^~^~~^-' 13 60
            ;;

        2)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Użytkownicy w systemie" \
                --msgbox "\n$(cat /etc/passwd | cut -d: -f1)" 10 60
            ;;

        3)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Grupy, do których należych" \
                --msgbox "\n$(groups | tr ' ' '\n')" 10 60
            ;;

        4)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Zainstalowanie środowiska graficzne" \
                --msgbox "\n$(ls /usr/share/xsessions/ | sed 's/\.desktop$//')" 10 60
            ;;

        5)
            if [ -n "$czy_root" ]; then
                debug "Zmiana daty systemowej"
                menu_4_nowa_data=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Zmiana daty systemowej" \
                    --inputbox "Podaj nową datę systemową (RRRR-MM-DD):" $menu_wymiary)
                debug $menu_4_nowa_data
                date -s "$menu_4_nowa_data"
            else
                blad_brak_roota "zmienić datę systemową"
            fi
            ;;

        6)
            if [ -n "$czy_root" ]; then
                menu_4_nowa_godzina=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Zmiana czasu systemowego" \
                    --inputbox "Podaj nowy czas systemowy (GG:MM:SS):" $menu_wymiary)
                debug $menu_4_nowa_godzina
                date -s "$menu_4_nowa_godzina"
            else
                blad_brak_roota "zmienić czas systemowy"
            fi
            ;;

        7)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Konfiguracja sieci" --msgbox "$(ifconfig)" 20 80
            ;;

        8)
            if [ -n "$czy_root" ]; then
                menu_7_wybor=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Zmiana konfiguracji sieci" \
                    --menu "Wybierz opcję:" $menu_wymiary 1 1 "Automatyczna konfiguracja (DHCP)" 2 "Ręczne wprowadzenie parametrów" )

                    case $menu_7_wybor in
                    1)
                        dhclient
                        ;;
                    2)
                        menu_7_interfejs=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Ręczna konfiguracja sieci" \
                            --inputbox "Podaj nazwę interfejsu sieciowego:" $menu_wymiary)
                        menu_7_ip=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Ręczna konfiguracja sieci" \
                            --inputbox "Podaj adres IP:" $menu_wymiary)
                        menu_7_maska=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Ręczna konfiguracja sieci" \
                            --inputbox "Podaj maskę podsieci:" $menu_wymiary)
                        menu_7_brama=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Ręczna konfiguracja sieci" \
                            --inputbox "Podaj bramę:" $menu_wymiary) 
                        menu_7_dns=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Ręczna konfiguracja sieci" \
                            --inputbox "Podaj DNS:" $menu_wymiary)

                        ifconfig $menu_7_interfejs $menu_7_ip netmask $menu_7_maska
                        route add default gw $menu_7_brama
                        echo "nameserver $menu_7_dns" > /etc/resolv.conf
                        ;;
                    esac
            else
                blad_brak_roota "zmienić konfigurację sieci"
            fi
            ;;

        9)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Czas uruchomienia systemu" \
                --msgbox "\n System jest uruchomiony od $(konwertuj_czas $(awk '{print int($1)}' /proc/uptime))." 6 64
            ;;

        10) 
            #Do naprawienia
            menu_9_wybor=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Utwórz komunikat wyświetlany raz dziennie" \
                --menu "Wybierz treść komunikatu:" 9 60 1 \
                1 "\"Lubię uczyć się do egzaminu INF.02.\"" \
                2 "Wprowadź własną treść" )
            case $menu_9_wybor in
                1)
                    (crontab -l 2>/dev/null; echo "0 12 * * * DBUS_SESSION_BUS_ADDRESS=/run/user/1000/path DISPLAY=:0 notify-send 'Lubię uczyć się do egzaminu INF.02.'") | crontab -
                    (crontab -l 2>/dev/null; echo "0 12 * * * mkdir /tmp/kaka") | crontab -
                    ;;
                2)
                    dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Utwórz komunikat wyświetlany raz dziennie" --inputbox "Podaj treść komunikatu:" $menu_wymiary > /etc/cron.daily/komunikat_menu_linux
                    ;;
            esac
            ;;

        11)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Pliki tymczasowe" --msgbox "\n$(ls /tmp/)" 20 60
            ;;

        12)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Usuwanie plików tymczasowych" \
            --msgbox "$(rm -rf /tmp/*)\n   Pliki tymczasowe zostały usunięte." 6 45
            ;;

        13)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Wolne miejsce na dyskach" --msgbox "$(df -h)" 12 55
            ;;

        14)
            menu_14_wielkosc=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Pliki o danej wielkości" \
            --inputbox "Podaj minimalną wielkość pliku (w KB):" 8 45)

            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Pliki większe niż $menu_14_wielkosc KB" \
            --msgbox "$(find / -type f -size +${menu_14_wielkosc}k | nl)" 15 80
            ;;

        15)
            touch "/tmp/umask1-$(date +%H:%M:%S)" #Sprawdzenie czy umask zadziałał
            menu_15_umask=$(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Umask" \
            --inputbox "Podaj nową wartość umask (aktualnie - $(umask)):" 7 50)
            umask $menu_15_umask
            touch "/tmp/umask2-$(date +%H:%M:%S)" #Sprawdzenie czy umask zadziałał
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Umask" --msgbox "\n  Nowy umask to $(umask) ($(umask -S))." 6 45
            debug "Nowy umask: $(umask -S)"
            ;;

        16)
            if [ -n "$czy_root" ]; then
                passwd -l $(dialog --stdout --backtitle "(c) Jakub Szczepa 2024" --title "Blokada konta" \
                --inputbox "Podaj nazwę użytkownika, którego konto chcesz zablokować:" $menu_wymiary)
            else
                blad_brak_roota "zablokować konto użytkownika"
            fi
            ;;

        17)
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Zrzut ekranu" \
            --inputbox "Podaj nazwę pliku, do którego chcesz zapisać zrzut ekranu:" $menu_wymiary 2> /tmp/zrzut
            ;;

        18)
            #Naprawić pytania bez odpowiedzi
            dialog --backtitle "(c) Jakub Szczepa 2024" --title "Egzamin próbny" \
            --yesno "\n Egzamin składa się z 5 pytań. Każde
            \n pytanie ma cztery odpowiedzi (A, B, C, D), 
            \n z czego tylko jedna jest poprawna. Czas na 
            \n rozwiązanie egzaminu jest nieograniczony.
            \n\n    Czy chcesz rozpocząć teraz egzamin?" 11 48

            if [ $? -eq 0 ]; then
                egzamin
            fi
            ;;

        19)
            debug "Odliczanie do wylogowania użytkownika"
            gnome-session-quit --logout > /dev/null 2>&1 &
            menu_19_pid=$!

            #Nie działa :<
            for menu_19_i in $(seq 60 -1 1); do
                dialog --backtitle "(c) Jakub Szczepa 2024" --title "Wylogowanie użytkownika" --infobox "\n Zostaniesz wylogowany za $menu_19_i sekund.\n Aby anulować, kliknij przycisk Anuluj." 6 45
                sleep 1
            
                if ! $(kill -0 $menu_19_pid > /dev/null 2>&1); then
                    debug "Wylogowanie użytkownika anulowane"
                    break
                fi
            done
            ;;

        20)
            debug "Odliczanie do wyłączania systemu"
            gnome-session-quit --power-off > /dev/null 2>&1 &
            menu_20_pid=$!

            for menu_20_i in $(seq 60 -1 1); do
                dialog --backtitle "(c) Jakub Szczepa 2024" --title "Wyłączanie systemu" --infobox "\n System zostanie wyłączony za $menu_20_i sekund.\n Aby anulować, kliknij przycisk Anuluj." 6 45
                sleep 1
            
                if ! $(kill -0 $menu_20_pid > /dev/null 2>&1); then
                    debug "Wyłączanie systemu anulowane"
                    break
                fi
            done
            ;;

        *)
            status=2
            ;;

    esac
}



# Egzamin
egzamin() {
    egzamin_pyt_poprawne=0
    egzamin_pyt_niepoprawne=0
    egzamin_czas_start_godzina=$(date +%T)
    egzamin_czas_start_sekundy=$(date +%s)
    debug "Rozpoczęcie egzaminu: $egzamin_czas_start_godzina"

    # Sprawdzenie czy folder "egzamin" istnieje
    if [ -d "egzamin" ]; then
        debug "Folder 'egzamin' istnieje"
    else
        debug "Folder 'egzamin' nie istnieje. Tworzenie folderu..."
        mkdir egzamin
    fi

    # Sprawdzenie czy pliki istnieją
    if [ -f "egzamin/img1.jpg" ] && [ -f "egzamin/img3.jpg" ] && [ -f "egzamin/img5.jpg" ]; then
        debug "Obrazki potrzebne do egzaminu istnieją"
    else
        debug "Obrazki potrzebne do egzaminu nie istnieją. Pobieranie ich..."
        wget -O egzamin/img1.jpg https://egzamin-informatyk.pl/old/640.jpg 2>&1 /dev/null
        wget -O egzamin/img3.jpg https://egzamin-informatyk.pl/e13/362.jpg 2>&1 /dev/null
        wget -O egzamin/img5.jpg https://egzamin-informatyk.pl/testimg/092379fa191d643b.png 2>&1 /dev/null 
    fi
    
    # Pytania
    # Źródło pytań: https://egzamin-informatyk.pl
    xdg-open egzamin/img1.jpg
    egzamin_pyt1_odp=$(dialog --backtitle "(c) Jakub Szczepa 2024" --title "Egzamin - Pytanie 1" \
        --menu "Element dekodujący instrukcje został na obrazku oznaczony cyfrą" 11 70 4 \
        "A" "3" \
        "B" "6" \
        "C" "1" \
        "D" "2" 2>&1 >/dev/tty)
        debug "Wybrano odpowiedź $egzamin_pyt1_odp"

        if [ "$egzamin_pyt1_odp" == "A" ]; then
            egzamin_pyt1_wynik="poprawna odpowiedź (A)"
            egzamin_pyt_poprawne=$((egzamin_pyt_poprawne+1))
        else 
            if [ "$egzamin_pyt1_odp" == "" ]; then
                egzamin_pyt1_wynik="nie podano odpowiedzi, zamiast: A"
            else
                egzamin_pyt1_wynik="niepoprawna odpowiedź ($egzamin_pyt1_odp), zamiast: A"
                egzamin_pyt_niepoprawne=$((egzamin_pyt_niepoprawne+1))
            fi
        fi
        pkill eog

    egzamin_pyt2_odp=$(dialog --backtitle "(c) Jakub Szczepa 2024" --title "Egzamin - Pytanie 2" \
        --menu "Która czynność NIE służy do personalizacji systemu Windows?" 11 70 4 \
        "A" "Ustawienie domyślnej przeglądarki internetowej." \
        "B" "Ustawienie wielkości pliku wymiany." \
        "C" "Ustawienie opcji wyświetlania pasków menu i pasków narzędziowych." \
        "D" "Ustawienie koloru tła pulpitu." 2>&1 >/dev/tty)
        debug "Wybrano odpowiedź $egzamin_pyt2_odp"

        if [ "$egzamin_pyt2_odp" == "B" ]; then
            egzamin_pyt2_wynik="poprawna odpowiedź (B)"
            egzamin_pyt_poprawne=$((egzamin_pyt_poprawne+1))
        else 
            if [ "$egzamin_pyt2_odp" == "" ]; then
                egzamin_pyt2_wynik="nie podano odpowiedzi, zamiast: B"
            else
                egzamin_pyt2_wynik="niepoprawna odpowiedź ($egzamin_pyt2_odp), zamiast: B"
            fi
        fi

    xdg-open egzamin/img3.jpg
    egzamin_pyt3_odp=$(dialog --backtitle "(c) Jakub Szczepa 2024" --title "Egzamin - Pytanie 3" \
        --menu "Przedstawione parametry karty sieciowej wskazują, że karta" 11 70 4 \
        "A" "nie zapewnia szyfrowania danych" \
        "B" "pracuje w sieciach przewodowych w oparciu o gniazdo USB" \
        "C" "pracuje w sieciach bezprzewodowych" \
        "D" "pracuje w standardzie c" 2>&1 >/dev/tty)
        debug "Wybrano odpowiedź $egzamin_pyt3_odp"

        if [ "$egzamin_pyt3_odp" == "C" ]; then
            egzamin_pyt3_wynik="poprawna odpowiedź (C)"
            egzamin_pyt_poprawne=$((egzamin_pyt_poprawne+1))
        else 
            if [ "$egzamin_pyt3_odp" == "" ]; then
                egzamin_pyt3_wynik="nie podano odpowiedzi, zamiast: C"
            else
                egzamin_pyt3_wynik="niepoprawna odpowiedź ($egzamin_pyt3_odp), zamiast: C"
            fi
        fi
        pkill eog

    egzamin_pyt4_odp=$(dialog --backtitle "(c) Jakub Szczepa 2024" --title "Egzamin - Pytanie 4" \
        --menu "Gdy w systemie Linux plik ma uprawnienia 541, to właściciel może" 11 70 4 \
        "A" "tylko wykonać plik" \
        "B" "odczytać, zapisać i wykonać plik" \
        "C" "modyfikować plik" \
        "D" "odczytać i wykonać plik" 2>&1 >/dev/tty)
        debug "Wybrano odpowiedź $egzamin_pyt4_odp"

        if [ "$egzamin_pyt4_odp" == "D" ]; then
            egzamin_pyt4_wynik="poprawna odpowiedź (D)"
            egzamin_pyt_poprawne=$((egzamin_pyt_poprawne+1))
        else 
            if [ "$egzamin_pyt4_odp" == "" ]; then
                egzamin_pyt4_wynik="nie podano odpowiedzi, zamiast: D"
            else
                egzamin_pyt4_wynik="niepoprawna odpowiedź ($egzamin_pyt4_odp), zamiast: D"
            fi
        fi

    xdg-open egzamin/img5.jpg
    egzamin_pyt5_odp=$(dialog --backtitle "(c) Jakub Szczepa 2024" --title "Egzamin - Pytanie 5" \
        --menu "Cechy której topologii fizycznej sieci zostały opisane na obrazku?" 11 70 4 \
        "A" "Magistrali." \
        "B" "Rozgłaszania." \
        "C" "Gwiazdy." \
        "D" "Siatki." 2>&1 >/dev/tty)
        debug "Wybrano odpowiedź $egzamin_pyt5_odp"

        if [ "$egzamin_pyt5_odp" == "A" ]; then
            egzamin_pyt5_wynik="poprawna odpowiedź (A)"
            egzamin_pyt_poprawne=$((egzamin_pyt_poprawne+1))
        else 
            if [ "$egzamin_pyt5_odp" == "" ]; then
                egzamin_pyt5_wynik="nie podano odpowiedzi, zamiast: A"
            else
                egzamin_pyt5_wynik="niepoprawna odpowiedź ($egzamin_pyt5_odp), zamiast: A"
            fi
        fi
        pkill eog

    egzamin_czas_koniec_godzina=$(date +%T)
    egzamin_czas_koniec_sekundy=$(date +%s)
    debug "Zakończenie egzaminu: $egzamin_czas_koniec_godzina"



    # Statystyki końcowe
    egzamin_czas=$(konwertuj_czas $(($egzamin_czas_koniec_sekundy - $egzamin_czas_start_sekundy)))
    debug "Zakończono egzamin. Czas trwania: $egzamin_czas"

    dialog --backtitle "(c) Jakub Szczepa 2024" --title "Statystyki" \
        --msgbox "          Egzamin został zakończony. \
        \n\nUżytkownik rozwiązujący: $(whoami) \
        \nGodzina rozpoczęcia: $egzamin_czas_start_godzina \
        \nGodzina zakończenia: $egzamin_czas_koniec_godzina \
        \nCzas trwania: $egzamin_czas \
        \n\nPoprawnie udzielonych odpowiedzi - $egzamin_pyt_poprawne \
        \nNiepoprawnie udzielonych odpowiedzi - $egzamin_pyt_niepoprawne \
        \nNieudzielonych odpowiedzi - $((5 - ( $egzamin_pyt_poprawne + $egzamin_pyt_niepoprawne) )) \
        \n\nPytanie 1: $egzamin_pyt1_wynik \
        \nPytanie 2: $egzamin_pyt2_wynik \
        \nPytanie 3: $egzamin_pyt3_wynik \
        \nPytanie 4: $egzamin_pyt4_wynik \
        \nPytanie 5: $egzamin_pyt5_wynik" 20 55
}



# Skrypt
    debug "Uruchomiono skrypt"

    # Sprawdzenie czy dialog jest zainstalowany
    if [ ! -x "$(command -v dialog)" ]; then
        echo "[Błąd] Brak programu dialog. Zainstaluj go, aby móc korzystać z tego skryptu."
        exit 1
    fi

    # Sprawdzenie czy użytkownik jest rootem
    if [ $EUID -eq 0 ]; then
        debug "Uruchomiono jako root"
        czy_root=1
    else
        debug "Uruchomiono jako zwykły użytkownik"
        czy_root=""

        dialog --backtitle "(c) Jakub Szczepa 2024" --title "Ostrzeżenie" \
            --yesno "\n Skrypt został uruchomiony bez\n uprawnień administratora. 
            \n Niektóre funkcje nie będą dostępne.\n\n   Czy mimo to chcesz kontynuować?" 10 42

        if [ $? -eq 0 ]; then
            debug "Użytkownik wybrał kontynuację"
        else
            debug "Użytkownik wybrał anulowanie"
            exit 0
        fi
    fi

    # Główna pętla
    while true; do
        debug "Status: $status"
        if [ -n "$status" ]; then
            debug "Zakończono skrypt"
            clear
            break
        fi
        menu_glowne
    done