#Requires AutoHotkey >=2.0- <2.1
#SingleInstance force  ; Ensures that only the last executed instance of script is running

#HotIf WinActive("Journal")   ; ---------- Alt under dette trigges bare fra journalvinduet. ----------

^+p::        ; <---- Hurtig send resept/sykemelding.
{
    Send "^p"
    Ekspeder()
    StickyKeyPrevention(ctrl:=true)
}

::-1i::     ; --------- Her kan du lage egen hurtig takst hotstring. Bare erstatt -1i med det du vil utløse hurtigtasten med og 1i mellom "" med taksten.
{
    Takste("1i")
    LukkJournal()
}

::-t::        ; <---- Send takst og lukk journal.
{
    tgui := Gui()
    tgui.Add("Text",, "Takst")
    tgui.Add("Edit", "vtakst")
    tgui.Add("Button", "default x+20", "Ok").OnEvent("Click", RunTakst)
    tgui.Show()

    RunTakst(*)
    {
    takst := tgui.Submit()
    Takste(takst.takst)
    LukkJournal()
    }
}

::-rp::	; <---- Forutsetter skrevet resept og diagnosekode satt. Takster 1i og sender e-kontakt. Setter ; foran EkontaktMedling og fjern foran HelseResponsSMS for å heller sende SMS via Helserespons.
{
    Takste("1i")
    EkontaktMelding(melding:="resept")
    ;HelseResponsSMS(melding:="resept", journalfør:=false)
    LukkJournal()
}

::-ute::        ; <---- Uteblitt fra konsultasjon. Takster (forutsetter at "ute" er registrert som takst). Journalfører at pas ikke har møtt og at faktura sendes. Sender ekontakt.
{
    Send "^+{F7}Kontaktårsak uspesifisert{Down}{Enter}"     ; Diagnosekode.
    WinWaitActive "Journal"
    Send "!5Ikke møtt til avtalt legetime. Faktureres for konsultasjonshonorar."
    Takste("ute")
    EkontaktMelding(melding:="uteblitt")
    LukkJournal()
}

^LButton::      ; <---- Forutsetter skrevet resept og diagnosekode satt. Ctrl-Click Reseptreseptfornyelse. Takster 1i og svarer reseptreseptfornyelse Helsenorge.
{
    Send "{Click}"      ; Click lenke til reseptfornyelse
    Sleep 1000
    Send "^+{e}"        ; Send elektronisk melding
    Send "{Ctrl Up 2}"
    LukkJournal(regning:=true)   ; Lukk journal og send regning
    StickyKeyPrevention(ctrl:=true)
}

::-råd::        ; <---- Råd dagtid, 1bd. Forutsetter diagnosekode satt.
{
    Send "!5Råd ok"
    Takste("1bd")
    LukkJournal()
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

::-obt::		    ; <---- Ortostatisk blodtrykk
{
    obtgui := Gui()
    obtgui.Add("Text",, "Pasienten ligger i minimum 5 minutter og flytter seg deretter fra liggende til stående stilling.")
    
    obtgui.Add("Text", "Section", "BT liggende:")
    obtgui.Add("Edit", "vobt1")
    obtgui.Add("Text",, "Puls liggende:")
    obtgui.Add("Edit", "Number vop1")

    obtgui.Add("Text", "ys", "BT 1 min stående:")
    obtgui.Add("Edit", "vobt2")
    obtgui.Add("Text",, "Puls 1 min stående:")
    obtgui.Add("Edit", "Number vop2")

    obtgui.Add("Text", "ys", "BT 3 min stående:")
    obtgui.Add("Edit", "vobt3")
    obtgui.Add("Text",, "Puls 3 min stående:")
    obtgui.Add("Edit", "Number vop3")

    obtgui.Add("Radio", "Checked vvenstre xm", "Venstre arm")
    obtgui.Add("Radio", "vhøyre x+20", "Høyre arm")

    obtgui.Add("Text", "x+20", "Cuff str: ")
    obtgui.Add("Radio", "Checked velleve x+20", "11")
    obtgui.Add("Radio", "vtolv x+20", "12")

    obtgui.Add("Button", "default x+20", "Ok").OnEvent("Click", WriteOBT)
    obtgui.Show()

    WriteOBT(*)
    {
    obt := obtgui.Submit()
    mål1 := StrSplit(obt.obt1,"/")
    mål2 := StrSplit(obt.obt2,"/")
    mål3 := StrSplit(obt.obt3,"/")

    if mål3[1]
    {
        systoliskfall := ( mål1[1] - Min(mål2[1],mål3[1]) )  ; systolisk liggende minus laveste systolisk stående
        diastoliskfall:= ( mål1[2] - Min(mål2[2],mål3[2]) )  ; diastolisk liggende minus laveste diastolisk stående
    }
    else
    {
        systoliskfall := ( mål1[1] - mål2[1] )  ; systolisk liggende minus laveste systolisk stående
        diastoliskfall:= ( mål1[2] - mål2[2] )  ; diastolisk liggende minus laveste diastolisk stående
    }
    if obt.op3
        pulsendring:= ( Max(obt.op2,obt.op3) - obt.op1 )  ; høyeste stående puls minus liggende puls
    else 
        pulsendring:= ( obt.op2 - obt.op1 )  ; høyeste stående puls minus liggende puls

    if obt.venstre
        arm := "Venstre"
    else
        arm := "Høyre"
    
    if obt.elleve
        cuffstr := 11
    if obt.tolv
        cuffstr := 12
    else
        cuffstr := 11

    WinActivate "Journal"
    WinWaitActive "Journal"
    Send "!3"
    if mål3[1]
        A_Clipboard := "Liggende BT: " obt.obt1 ", Puls: " obt.op1 "`rStående 1m BT: " obt.obt2 ", Puls: " obt.op2 "`rStående 3m BT: " obt.obt3 ", Puls: " obt.op3 "`r`rSystolisk BT fall: " systoliskfall " mmHg. Diastolisk BT fall: " diastoliskfall " mmHg. Pulsøkning: " pulsendring " bpm.`r" arm " arm (cuff str " cuffstr ")"
    else
        A_Clipboard := "Liggende BT: " obt.obt1 ", Puls: " obt.op1 "`rStående 1m BT: " obt.obt2 ", Puls: " obt.op2 "`r`rSystolisk BT fall: " systoliskfall " mmHg. Diastolisk BT fall: " diastoliskfall " mmHg. Pulsøkning: " pulsendring " bpm.`r" arm " arm (cuff str " cuffstr ")"
    Send A_Clipboard
    }
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

::-dcal::	; ----		Merk en dato (format: 01.01.2000) og skriv inn hvor mange tabletter er utlevert siden den datoen. Kalkulerer snittforbruk.
{
    AskForDate()
    
    DateCalculator(date)    ; Main part of script
    {
        Sleep 100
        datosplit := StrSplit( Trim(date) ,".")
        
        if StrLen(datosplit[1]) < 2             ; If month and date are only 1 digit, add zeroes.
            datosplit[1] := "0" . datosplit[1]
        if StrLen(datosplit[2]) < 2
            datosplit[2] := "0" . datosplit[2]
        
        fradato := datosplit[3] . datosplit[2] . datosplit[1]

        dager := DateDiff(A_Now, fradato, "days")

        datogui := Gui()
        datogui.Add("Text",, "Antall tabletter:")
        datogui.Add("Edit", "vantall")

        datogui.Add("Button", "default x+20", "&Ok").OnEvent("Click", CalculateDate)
        datogui.Show()

        CalculateDate(*)
        {
        tabletter := datogui.Submit()
        antalltbl := tabletter.antall
        forbruk := Round(antalltbl / dager, 1)

        Send "^1!5"
        Send "Utlevert " antalltbl " stk siden " date ". Tilsvarer snitt forbruk på " forbruk " daglig."
        }
    }

    DateCorrect(date)   ; Check if date is in correct format.
    {
        regex := "\d{1,2}\.\d{1,2}\.\d{4}"
        if RegExMatch(date, regex)
            return true
        else
            return false
    }

    AskForDate()    ; Ask for manual entry of date
    {
        askgui := Gui()
        askgui.Add("Text",, "Skriv fra dato (XX.XX.XXXX): ")
        askgui.Add("Edit", "vdate")
        askgui.Add("Button", "default x+20", "Ok").OnEvent("Click", GetDate)
        askgui.Show()

        GetDate(*)
        {
            ask := askgui.Submit()
            if DateCorrect(ask.date)
                DateCalculator(ask.date)    ; If entered correctly, run script.
            else
            {
                MsgBox "Feil format. Må skrives XX.XX.XXXX"
                AskForDate()
            }
        }
    }

}

::-beers::	; ----		Søk Beers list etter medikament.
{
    beergui := Gui()
    beergui.Add("Text",, "Medikament: ")
    beergui.Add("Edit", "vmed")
    beergui.Add("Button", "default x+20", "Ok").OnEvent("Click", SearchBeers)
    beergui.Show()

    SearchBeers(*)
    {
        beers := beergui.Submit()
        Webside("https://www.guidelinecentral.com/guideline/340784/","2023 Beers Criteria for Medication Use List - AGS Beer Criteria Guideline 2023")
        Sleep 500
        Send "^f" ; Find on page
        Send beers.med "{Enter}"
    }
}

^!a::	; ----		Søk på merket labprøve i labbildet på analyseoversikten.no
{
    Send "^c^c"
    regex := "([A-Z]*-)([A-Za-z]*)"
    RegexMatch(A_Clipboard , regex, &analyse)
    
    Run "https://www.analyseoversikten.no"
    Sleep 500
    Send "{Tab 9}"
    Send analyse[2]
    StickyKeyPrevention(ctrl:=true,alt=true)
}

; Resepter
::-apo6x5::     ; ----      Apocillin 660 mg x 4 i 5 dager
{
    SkrivResept("apocillin6x5")
}
::-apo1x5::     ; ----      Apocillin 1 g x 4 i 5 dager
{
    SkrivResept("apocillin1x5")
}
::-apo1x7::     ; ----      Apocillin 1 g x 4 i 7 dager
{
    SkrivResept("apocillin1x7")
}
::-apo1x10::     ; ----      Apocillin 1 g x 4 i 10 dager
{
    SkrivResept("apocillin1x10")
}
::-sel3x3::     ; ----      Selexid 200 mg x 3 i 3 dager
{
    SkrivResept("selexid3x3")
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

EkontaktMelding(melding,greeting:=true)
{
    meldinger := Map(
        "resept", ["E-resept sendt", "E-resept er sendt og kan hentes på valgfritt apotek.`r`rMvh`rPeter Lorens"],
        "uteblitt", ["Ikke møtt til time", "Da du ikke møtte til time i dag eller har avbestilt under 24 timer før timen vil du motta faktura fra Convene i tråd med 'Forskrift om stønad til dekning av utgifter til undersøkelse og behandling hos lege, Merknad B2'. Vi håper du tar kontakt igjen om du trenger ny time. Vennlig hilsen Fenring Legesenter"],
        "normlab", ["Prøvesvar", "Blodprøvene dine var normale."]
    )

    Send "{F9}E-kontakt, engangskontakt{Enter}"
    WinWaitActive("Opprett nytt dokument")
    if greeting
        Send "Hei,`r`r"
    Send "{Tab}" meldinger[melding][1] "{Enter}"
    if greeting
        Send "`r`rMvh`rPeter Lorens"
    Sleep 1500
    if WinExist("Advarsel")
        {
        return
        }
    Send meldinger[melding][2]
    Send "^+e"
    return
}

Ekspeder()
{
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

Webside(url,tittel)
{
    if WinExist(tittel)
        WinActivate
    else
        Run url
    WinWaitActive(tittel)
    return
}

SkrivResept(medkode)
{
    ; [1]Preparatnavn, [2]posisjon på listen, [3]Fast(1)-Behov(2)-Kurs(3), [4]Bruksområde, [5]Morgen, [6]Formoddag, [7]Midt på dag, [8]Ettermiddag, [9]Kveld, [10]Natt, [11]Dager
    medikament := Map(
        "apocillin6x5", ["apocillin", 6, 3, 4, 1, 1, 0, 1, 1, 0, 5],
        "apocillin1x5", ["apocillin", 1, 3, 4, 1, 1, 0, 1, 1, 0, 5],
        "apocillin1x7", ["apocillin", 2, 3, 4, 1, 1, 0, 1, 1, 0, 7],
        "apocillin1x10", ["apocillin", 3, 3, 4, 1, 1, 0, 1, 1, 0, 10],
        "selexid3x3", ["selexid", 4, 3, 2, 1, 0, 1, 0, 1, 0, 3]
    )
    
    Send "^3!k!ø{Tab}"  ; Sikre at man er på "Søk preparat"
    Sleep 100
    Send medikament[medkode][1]  ; Søk preparatnavn
    Sleep 200
    if medikament[medkode][2] = 1
        Send "{Enter}"

    Loop medikament[medkode][2] ; Velg preparat
    {
        Send "{Down}"
    }  

    Send "{Enter}"
    Sleep 200
    Send "!b"
    Loop medikament[medkode][4] ; Velg Bruksområde
    {
        Send "{Down}"
    }
    Send "{Tab 2}{Enter}"
    WinWaitActive "Strukturert dosering"
    Send "{Tab 5}" ; Velg Morgen dose
    Send medikament[medkode][5] "{Tab}"
    Send medikament[medkode][6] "{Tab}"
    Send medikament[medkode][7] "{Tab}"
    Send medikament[medkode][8] "{Tab}"
    Send medikament[medkode][9] "{Tab}"
    Send medikament[medkode][10] "{Tab 2}"
    if medikament[medkode][3] = 3
        Send medikament[medkode][11] "{Enter}"
    else
        Send "{Enter}"
    Sleep 100
    Send "!y"
    Loop medikament[medkode][3] ; Velg Fast, Behov, Kur
    {
        Send "{Down}"
    }
    Send "!g"
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

;-------------------------------;
;-------------------------------;
;-----Sticky Key Prevention-----;
;-------------------------------;
;-------------------------------;
; Skal forhindre at Ctrl og Alt
; setter seg fast. Men virker ikke 100%.

StickyKeyPrevention(ctrl:=false,alt:=false)
{
    if ctrl
        Send "{Ctrl down}{Ctrl up}{Ctrl down}{Ctrl up}"
    if alt
        Send "{Alt down}{Alt up}{Alt down}{Alt up}"
    return
}
