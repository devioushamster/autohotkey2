#Requires AutoHotkey >=2.0- <2.1
#SingleInstance force  ; Ensures that only the last executed instance of script is running

#HotIf WinActive("Journal")   ; ---------- Alt under dette trigges bare fra journalvinduet. ----------

^+p::        ; <---- Hurtig send resept/sykemelding. --Ctrl+Shift+P--
{
    Ekspeder()
}

::-rps::        ; <---- Forutsetter skrevet resept og diagnosekode satt. Takster 1i og sender SMS via HelseRespons.
{
    Takste("1i")
    HelseResponsSMS("resept")
    LukkJournal()
}

::-råd::        ; <---- Råd dagtid, 1bd. Forutsetter diagnosekode satt. Laget for ny Faktura modul.
{
    Send "!5Råd ok"
    Takste("1bd")
    LukkJournal()
}

::-rådlv::      ; <---- Råd legevakt, 1bk.  Forutsetter diagnosekode satt. Laget for gammel Økonomi modul.
{
    Send "!5Råd ok"
    Takste(takst:="1bk", lv:=true)
    LukkJournal(epikrise:=false, lv:=true)
}

::-bt::		    ; <---- Skriver BT/P mal under "Andre undersøkelser" og flytter markøren til *. [BT: * venstre (cuff str 11), Puls: ]
{
    Send "!3"
    Send "BT:  venstre (cuff str 11), Puls: {Left 30}"
}

::-bta::		    ; <---- BT/P 3 målinger, snitt av siste 2 BT målinger. Hvis den svikter i å skrive teksten kan man Ctrl-V da den lagres i clipboard.
{
    btgui := Gui()
    btgui.Add("Text",, "BT 1:")
    btgui.Add("Edit", "vbt1")
    btgui.Add("Text",, "Puls 1:")
    btgui.Add("Edit", "Number vp1")

    btgui.Add("Text", "ym", "BT 2:")
    btgui.Add("Edit", "vbt2")
    btgui.Add("Text",, "Puls 2:")
    btgui.Add("Edit", "Number vp2")

    btgui.Add("Text", "ym", "BT 3:")
    btgui.Add("Edit", "vbt3")
    btgui.Add("Text",, "Puls 3:")
    btgui.Add("Edit", "Number vp3")

    btgui.Add("Radio", "Checked vvenstre xm", "Venstre arm")
    btgui.Add("Radio", "vhøyre x+20", "Høyre arm")

    btgui.Add("Text", "x+20", "Cuff str: ")
    btgui.Add("Radio", "Checked velleve x+20", "11")
    btgui.Add("Radio", "vtolv x+20", "12")

    btgui.Add("Button", "default x+20", "Ok").OnEvent("Click", CalculateBT)
    btgui.Show()

    CalculateBT(*)
    {
    bt := btgui.Submit()
    mål2 := StrSplit(bt.bt2,"/")
    mål3 := StrSplit(bt.bt3,"/")

    snittbt := ( Round( (mål2[1] + mål3[1])/2 ) ) "/" ( Round( (mål2[2] + mål3[2])/2) )  ; systolisk/diastolisk
    if bt.venstre
        arm := "venstre"
    else
        arm := "høyre"
    
    if bt.elleve
        cuffstr := 11
    if bt.tolv
        cuffstr := 12
    else
        cuffstr := 11

    WinActivate "Journal"
    WinWaitActive "Journal"
    Send "!3"
    A_Clipboard := "BT: " bt.bt1 "->" bt.bt2 "->" bt.bt3 " " arm " arm (cuff str " cuffstr "), Puls: " bt.p1 "->" bt.p2 "->" bt.p3 " regelmessig `rSnitt BT: " snittbt ""
    Send A_Clipboard
    }
}

::-24bt::       ; <---- Oppsummerer statistikk dokumentet fra 24t BT. Fortsetter at man har åpnet PDF fra CardioPerfect 24t BT, Ctrl-A og Ctrl-C for å kopiere alt.
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
                %var% := RTrim( StrReplace(%var%," mmHg") , "`r`n")
            else
                %var% := RTrim( StrReplace(%var%," spm") , "`r`n")

        ; Assign variables
        sysmaks := line[42]
        sysmin := line[42]
        diamaks := line[52]
        diamin := line[53]
        hrmaks := line[65]
        hrmin := line[66]

        ; Split the string by mmHg ved or bpm ved, get array with bt at index 1 and time at index 2. Trim new line at end.
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

::-ute::        ; <---- Uteblitt fra konsultasjon. Takster (forutsetter at "ute" er registrert som takst). Journalfører at pas ikke har møtt og at faktura sendes. Sender SMS via HelseRespons og journalfører SMS.
{
    Send "^+{F7}Kontaktårsak uspesifisert{Down}{Enter}"     ; Diagnosekode.
    WinWaitActive "Journal"
    Send "!5Ikke møtt til avtalt legetime. Faktureres for konsultasjonshonorar."
    Takste("ute")
    HelseResponsSMS("uteblitt",journalfør:=true)
    LukkJournal()
}

::-bmi::        ; <---- Skriv inn høyde og vekt. Verdiene registreres i percentilskjema og BMI skrives i journalnotat i tillegg til høyde og vekt.
{
    bmigui := Gui()     ; GUI med felt til høyde og vekt.
    bmigui.Add("Text",, "Høyde (cm):")
    bmigui.Add("Edit", "vhøyde")
    bmigui.Add("Text", "ym", "Vekt (kg):")
    bmigui.Add("Edit", "vvekt")
    bmigui.Add("Button", "default", "Ok").OnEvent("Click", CalculateBMI)
    bmigui.Show()

    CalculateBMI(*)
    {
        bmicalc := bmigui.Submit()

        ; Convert to float, replace commmas with periods.
	    vekt := Round( Float(StrReplace(bmicalc.vekt , "," , ".")) , 2)
	    høyde := Round( Float(StrReplace(bmicalc.høyde , "," , ".")) , 2)
        ; Version with commas.
	    vekt_comma := StrReplace(vekt , "." , ",")
	    høyde_comma := StrReplace(høyde , "." , ",")

        bmi := Format("{:.2f}" , vekt / (høyde/100)**2) ; Kalkuler BMI
        Send "^7^r" vekt_comma "{Tab}" høyde_comma "{Enter}^1!3"    ; Registrer høyde og vekt i percentilskjema.
        Send "BMI: " bmi    ; Lim BMI inn i 2 - Andre us.
        
    }
}

#HotIf ; ---------------- Alt over dette trigges bare fra journalvinduet. ----------------

/* 
---------------------
------Functions------
---------------------
*/

Takste(takst, lv:=false, test:=false)       
{
    Send "^q"

    if lv ; <---- Sender regning med angitt takst, Infodoc Økonomi (gammel modul).
        {
        WinWaitActive("Økonomi", , 2)
        Sleep 500
        Send "" takst "{Enter}^g{Enter}"
        }
    else ; <---- Sender regning med angitt takst, Infodoc Faktura.
        {
        WinWaitActive("Faktura", , 2)
        Sleep 500
        Send "" takst "{Enter}"
        Sleep 500
        Send "^b"
        }

    WinWaitActive("Journal")
    return
}

LukkJournal(regning:=false, lv:=false, epikrise:=false, test:=false)       
{
    Sleep 500

    if lv ; <---- Lukker legevaktsjournal og huker av for at epikrise ikke sendes fastlege (f.eks. råd).
        {
        Send "!{F4}"
        WinWaitActive ("Signering av notat i journal")
        if (epikrise=false)
            Send "!e"
        Send "!s"
        }
    else ; <---- Lukker journalen.
        {
        if regning
            Send "!{F4}!b"
        else
            Send "!{F4}{Enter}"
        return
        }
}

HelseResponsSMS(melding, journalfør:=false)
{
    sms_meldinger := Map(
        "resept", "E-resept er sendt og kan hentes på valgfritt apotek. Vennling hilsen Fenring Legesenter",
        "uteblitt", "Da du ikke møtte til time i dag eller har avbestilt under 24 timer før timen vil du motta faktura fra Convene. Vi håper du tar kontakt igjen om du trenger ny time. Vennlig hilsen Fenring Legesenter"
    )
    
    Send "+^!s"
    WinWaitActive("Ny melding")
    Send "{Tab}{Enter}"         ; Velg send SMS
    WinWaitActive("Ny SMS")
    Sleep 50
    if WinExist("Søk etter pasientjournal") ; Vent 5 sekunder på valg av telefonnummer
        WinWaitActive("Ny SMS",,5)
    Sleep 200
    Send sms_meldinger[melding]
    Send "{Tab}"                ; Merk Journalfør utgående SMS
    if journalfør
        Send "{Space}"          ; Huk av for journalfør
    Sleep 500
    Send "{Tab}{Enter}"
    WinWaitActive("Journal")
}

Ekspeder()
{
    Send "^p{Ctrl up 2}"
    Winwaitactive("Skriv")  
    if WinExist("Skriv ut / send sykmelding")
        Send "!o"

    if WinExist("Skriv ut/send/lagre") {
        Send "!o"
        Winwaitactive("Forhåndsvisning av meldinger")
        Send "{Enter}"
    }
    return
}