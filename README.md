# AutoHotkey v2 scripts til deling
**!! Disse er skrevet med AutoHotkey v2. De fungerer ikke med AutoHotkey v1. !!**

> **Laget til Infodoc Plenario med ny Faktura modul med mindre annet er spesifisert.**
- **Ctrl-Shift-P** for hurtig sending av sykemelding/resept. Hopper over alt før du skriver inn PIN koden.
- **-rps** Takster 1i, sender SMS via HelseRespons (må velge telefonnummer hvis det er flere) og lukker journal. Forutsetter at man har lagt inn diagnosekode først.
- **-råd** Takster 1bd, skriver "Råd ok" og lukker journal. Forutsetter at man har lagt inn diagnosekode først.
- **-rådlv** Takster 1bk, skriver "Råd ok" og lukker journal (trykker vekk send epikrise sånn at det ikke sendes, dette vil da sende epikrise hvis man har satt det opp slik at den boksen ikke er huket av ved default). Forutsetter at man har lagt inn diagnosekode først. **Virker kun med gammel Økonomi modul.**
- **-bt** Skriver BT/P mal under "Andre undersøkelser" og flytter markøren til *. [BT: * venstre (cuff str 11), Puls: ]
- **-bta** Kommer opp en boks, man skriver inn 3xBT/P, kan velge hvilken arm og cuff størrelse. Den skriver inn resultat under "Andre undersøkelser". Hvis den ikke skulle skrive resultat er det også lagret i clipboard, bare Ctrl-V.
    > BT: 120/80->120/80->120/80 Venstre arm (cuff str 11), Puls: 60->60->60 regelmessig\
    Snitt BT: 120/80
- **-ute** Takster (forutsetter at "ute" er registrert som takst). Journalfører at pasienten ikke har møtt og at faktura sendes. Sender SMS via HelseRespons og journalfører SMS. Lukker journal.
- **-bmi** Kommer opp en boks. Skriv inn høyde og vekt. Verdiene registreres i percentilskjema og BMI skrives i journalnotat i tillegg til høyde og vekt.
- **-24bt** Oppsummerer statistikk dokumentet fra 24t BT (CardioPerfect). Fortsetter at man har åpnet statistikk PDF, Ctrl-A og Ctrl-C for å kopiere alt.
