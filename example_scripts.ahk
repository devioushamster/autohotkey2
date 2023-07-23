#Requires AutoHotkey v2.0
#SingleInstance force  ; Ensures that only the last executed instance of script is running

::-24bt::       ; <---- Oppsummerer statistikk dokumentet fra 24t BT.
{
    If SubStr(A_Clipboard,1,5) == "Navn:" {     ; Check if clipboard contains the correct contents.
        btmålinger := Array()
        Loop parse, A_Clipboard, "`n"           ; Save clipboard contents in an array, one line per index.
        {
            btmålinger.Push A_LoopField
        }

        Send "!3"
        Skriv24tMålinger(btmålinger)

    }
    Else {
        Exit
    }

    Skriv24tMålinger(line)
    {   
        ; Remove extra text, split percentages by spaces (one per index).
        vellykket := StrSplit( StrReplace(line[82],"% vellykket ") , " " )

        ; Assign variables
        btsnitt := line[25]
        btdag := line[30]
        btnatt := line[35]
        hrsnitt := line[63]
        hrdag := line[67]
        hrnatt := line[71]

        ; Remove mmHg and spm. Trim new line from end of all variables.
        for var in [&btsnitt, &btdag, &btnatt, &hrsnitt, &hrdag, &hrnatt]
            if InStr(%var%," mmHg")
                {
                %var% := RTrim( StrReplace(%var%," mmHg") , "`r`n")
                }
            else
                %var% := RTrim( StrReplace(%var%," spm") , "`r`n")

        ; Assign variables
        sysmaks := line[42]
        sysmin := line[42]
        diamaks := line[52]
        diamin := line[53]
        hrmaks := line[65]
        hrmin := line[66]

        ; Split the string by ekstra text, get array with bt at index 1 and time at index 2. Trim new line at end.
        for var in [&sysmaks, &sysmin, &diamaks, &diamin, &hrmaks, &hrmin]
            if InStr(%var%," mmHg ved ")
                %var% := StrSplit(%var%," mmHg ved ","`r`n")
            else
                %var% := StrSplit(%var%," bpm ved ","`r`n")

        ; Write summary
        ; Line 82 (%) and lines 25, 30, 35 | vellykket := StrSplit(StrReplace(line[82],"% vellykket "")," ") | btsnitt := StrReplace(line[25]," mmHg")
        Send "24-timers Blodtrykk: Gjennomsnitt (" vellykket[1] " vellykket) " btsnitt " - Dag (" vellykket[2] ") " btdag " - Natt (" vellykket[3] ") " btnatt "`n"
        ; Lines 42, 43, 52, 53 | sysmaks := StrSplit(line[42]," mmHg ved ")
        Send "Systolisk Maks: " sysmaks[1] " (kl " sysmaks[2] ") - Min: " sysmin[1] " (kl " sysmin[2] ") | Diastolisk Maks: " diamaks[1] " (kl " diamaks[2] ") - Min: " diamin[1] " (kl " diamin[2] ")`n"
        ; Lines 63, 67, 71, 65, 66 | hrsnitt := StrReplace(line[63]," spm") | hrmaks := StrSplit(line[65]," bpm ved ")
        Send "Hjertefrekvens: Gjennomsnitt " hrsnitt " - Dag " hrdag " - Natt " hrnatt " | Maks " hrmaks[1] " (kl " hrmaks[2] ") - Min " hrmin[1] " (kl " hrmin[2] ")`n"
        ; Line 78 | 10,4% / 10,8% (Ikke en dipper)
        Send "Dag/natt senkning (sys/dia): " RTrim(line[78],"`r`n") ""
    }
}
