# AutoHotkey v2 scripts til deling
**!! Disse er skrevet med AutoHotkey v2. De fungerer ikke med AutoHotkey v1. !!**

> **Laget til Infodoc Plenario med ny Faktura modul med mindre annet er spesifisert.**

## Taksting
** Første gang Faktura modulen åpner seg kan den være treig. Da kan det være taksten ikke blir skrevet inn. Hvis man skriver taksten manuelt og sender regning vil skriptet fortsette når du kommmer tilbake til journalen. **
- **-råd** Takster 1bd, skriver "Råd ok" og lukker journal. Forutsetter at man har lagt inn diagnosekode først.
- **-t** Åpner vindu, du skriver en takst. Takster kun den taksten og lukker journalen. Forutsetter diagnosekode.

## Taksting med melding til pasient
** Her kan man velge mellom å sende e-kontakt eller SMS via HelseRespons for de som har det. E-kontakt er lagt inn som standard men kan kommenteres ut og HelseRespons kan brukes istedenfor. **
- **-ute** Takster (forutsetter at "ute" er registrert som takst). Journalfører at pasienten ikke har møtt og at faktura sendes. Sender SMS via HelseRespons og journalfører SMS. Lukker journal.
- **-rp** Takster 1i, sender melding til pasient og lukker journal. Forutsetter at man har lagt inn diagnosekode først.
- **Ctrl-Venstre Mustrykk** Til Reseptfornyelse via helsenorge. Forutsetter skrevet resept og diagnosekode. Ctrl klikk med reseptfornyelse meldingen åpen. Sender svar på meldingen (som automatisk takster 1i) og lukker journalen.

## Annet
- **Ctr-Alt-I** for å bytte direkte til eget signatur i et journalnotat. Må tilpasses eget signatur.

## Relativt stabile
** Virker stort sett for meg, men noen små feil kan skje. **
- **Ctrl-Shift-P** for hurtig sending av sykemelding/resept. Hopper over alt før du skriver inn PIN koden. **Opplever at Ctrl og Alt han "sette seg fast" av og til, hvis man trykker litt på de knappene fikser det seg.**
- **-bt** Skriver BT/P mal under "Andre undersøkelser" og flytter markøren til *. [BT: * venstre (cuff str 11), Puls: ]
- **-bta** Kommer opp en boks, man skriver inn 3xBT/P, kan velge hvilken arm og cuff størrelse. Den skriver inn resultat under "Andre undersøkelser". Hvis den ikke skulle skrive resultat er det også lagret i clipboard, bare Ctrl-V.
    > BT: 120/80->120/80->120/80 Venstre arm (cuff str 11), Puls: 60->60->60 regelmessig\
    Snitt BT: 120/80
- **-obt** Som -bta, men til ortostatisk blodtrykk.
    > Liggende BT: 120/80, Puls: 60\
    Stående 1m BT: 120/80, Puls: 60\
    Stående 3m BT: 120/80, Puls: 60\
    Systolisk fall: 0 mmHg, Diastolisk fall: 0 mmHg, Pulsøkning: 0 bpm\
    Venstre arm (cuf str 11)
- **-24bt** Oppsummerer statistikk dokumentet fra 24t BT (CardioPerfect). Fortsetter at man har åpnet statistikk PDF, Ctrl-A og Ctrl-C for å kopiere alt.
- **-bmi** Kommer opp en boks. Skriv inn høyde og vekt. Verdiene registreres i percentilskjema og BMI skrives i journalnotat i tillegg til høyde og vekt.

## Eksperimentelle
** Kun testet litt, kan ikke love at de virker 100% **
- Hurtig reseptskriving
    - **-apo6x5** Apocillin 660 mg x 4 i 5 dager
    - **-apo1x5** Apocillin 1 g x 4 i 5 dager
    - **-apo1x7** Apocillin 1 g x 4 i 7 dager
    - **-apo1x10** Apocillin 1 g x 4 i 10 dager
    - **-sel3x3** Selexid 200 mg x 3 i 3 dager
- **-dcal** Regne snitt forbruk av medikament. Skriv inn dato for siste utlevering (eller flere utleveringer siden hvis du vil ha snitt over tid). Skriv inn antall tabletter utlevert. Regner ut og skriver i 5. Vurdering.
    > Utlevert 100 stk siden 1.1.2024. Tilsvarer snitt forbruk på 2.5 daglig.
- **Ctrl-Alt-A** Analysesøk fra labark. Merk en labanalyse og trykk ctrl-alt-a. Åpner nettleser og søker i Analyseoversikten.no.
- **-beers** Søk Beers list etter medikament. Kommer opp en boks. Skriv navn på virkestoff (på engelsk). Søker i Beers list om den står der.