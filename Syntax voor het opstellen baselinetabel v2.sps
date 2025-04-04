* Encoding: UTF-8.
* Encoding: .

*/Inhoudsopgave coderingssyntax: 
-Regel 11 t/m 80: openen en aanpassen van de variabelen in het PAT bestand (DataSet1)
-Regel 82 t/m 153: openen en aanpassen van het EPS bestand (DataSet2)
-Regel 155: vanaf hier de variabele ICPC gerecodeerd
    - Regel 160 t/m 230 variabele gemaakt voor diabetes alle. Regel 244 t/m 252 variabele aangemaakt voor duur diabetes.

* Encoding: UTF-8.

*/ PAT bestand openen middels import data CSV file. Bij 'read CSV file' karakteristieken van het PAT bestand aangegeven zodat SPSS het kan lezen: decimal symbol= dot en delimiters= tab. 
*/ PAT bestand (=DataSet1) als basis gebruikt waar vervolgens alle variabelen, uit de andere bestanden, essentieel voor de baseline tabel aan worden toegevoegd. 

PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE="I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS "+
    "analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor "+
    "baseline\PAT_DataSet1.csv"
  /ENCODING='UTF8'
  /DELIMITERS="\t"
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  Extractiedatum AUTO
  Systeem AUTO
  PATNR AUTO
  PRAKNR AUTO
  iGeboortejaar AUTO
  iOverlijdensjaar AUTO
  dGeslacht AUTO
  dInschrijfdatum AUTO
  dUitschrijfdatum AUTO
  /MAP.
RESTORE.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

*/ Om het bestand te comprimeren voor nu een de variabelen Systeem, PRAKNR, dInschrijfdatum en dUitschrijfdatum verwijderd.
*/ Ervanuit gaande dat de meeste ICPC's geen einddatum hebben omdat ze chronische ziektes betreffen, de variabele Einddatum verwijderd.
*/ Tevens is de frequency van Einddatum (het aantal geregistreerde einddata van de verschillende ICPC) is erg laag. 

DELETE VARIABLES Systeem.
DELETE VARIABLES PRAKNR.

*/ Alle variabelen gelabeld 

VARIABLE LABELS PATNR 'Patiëntnummer'.
VARIABLE LABELS iGeboortejaar 'Geboortejaar'.
VARIABLE LABELS iOverlijdensjaar 'Jaar van overlijden'.
VARIABLE LABELS dGeslacht 'Geslacht'.
VARIABLE LABELS iGeboortejaar 'Geboortejaar'.
VARIABLE LABELS iOverlijdensjaar 'Overlijdensjaar'.

*/ Ter verheldering variabelen hernoemd. 

RENAME VARIABLES (iGeboortejaar=Geboortejaar).
RENAME VARIABLES (iOverlijdensjaar=Overlijdensjaar).

*/ Extractiedatum, Inschrijfdatum en Uitschrijfdatum ingekort naar 10 decimals van jaar-maand-dag-uur-tijd naar jaar-maand-dag. Vervolgens omgezet in variable type 'date'. 

ALTER TYPE Extractiedatum (a10).
ALTER TYPE Extractiedatum (sdate10).
ALTER TYPE dInschrijfdatum (a10).
ALTER TYPE dInschrijfdatum (sdate10).
ALTER TYPE dUitschrijfdatum (a10).
ALTER TYPE dUitschrijfdatum (sdate10).

*/ Zodra de variable type van dGeslacht 'numeric' is kan hiervan de frequency worden bepaald, dus dGeslacht gerecodeerd voor man=1 vrouw=0. 
*/ 0 en 1 codering vastleggen in value labels

DATASET ACTIVATE DataSet1.
RECODE dGeslacht ('M'=1) ('V'=0) INTO Geslacht. 
VALUE LABELS Geslacht 1 'M' 0 'V'. 

VARIABLE LABELS Geslacht 'Geslacht'.

*/ Variabele dGeslacht is nu dubbelop/overbodig dus verwijderd.

DELETE VARIABLES dGeslacht. 

*/ iOverlijdensjaar is een numerieke variabele. We willen weten: overleden ja/nee. Variabele Overlijdensjaar gecodeerd met een binaire uitkomst.

RECODE Overlijdensjaar (0 thru Highest=1) (ELSE=0) INTO Overleden.
VARIABLE LABELS  Overleden 'Overleden'.
EXECUTE.

VALUE LABELS Overleden 1'Overleden'.

*/ Gecontroleerd of alle overleden patienten ook de variabele dUitschrijfdatum hebben. Overlijden heeft alleen een jaar dus het jaargetal geëxtraheerd uit Extractiedatum.

* Date and Time Wizard: Extractie_jaar.
COMPUTE Extractie_jaar=XDATE.YEAR(Extractiedatum).
VARIABLE LABELS Extractie_jaar "Jaar extractie gegevens".
VARIABLE LEVEL Extractie_jaar(NOMINAL).
FORMATS Extractie_jaar(F8.0).
VARIABLE WIDTH Extractie_jaar(8).
EXECUTE.

*/ Vervolgens Overlijdensjaar van Extractiejaar afgetrokken. 

COMPUTE TijdTussenExtractie_Overlijden=(Extractie_jaar) - (Overlijdensjaar).
EXECUTE.

*/ Overlijden heeft alleen een jaar dus het jaargetal geëxtraheerd uit dUitschrijfdatum.

* Date and Time Wizard: JaarUitschrijven.
COMPUTE JaarUitschrijven=XDATE.YEAR(dUitschrijfdatum).
VARIABLE LABELS JaarUitschrijven "Jaar van uitschrijven".
VARIABLE LEVEL JaarUitschrijven(NOMINAL).
FORMATS JaarUitschrijven(F8.0).
VARIABLE WIDTH JaarUitschrijven(8).
EXECUTE.

*/ Overlijdensjaar van JaarUitschrijven afgetrokken. 

COMPUTE TijdTussenUitschrijven_Overlijden=(JaarUitschrijven) - (Overlijdensjaar).
EXECUTE.

*/ PM: Analyze descriptive statistics laat zien dat TijdTussenUitschrijven_Overlijden bij alle 217 overleden patienten 0 is, dus na overlijden wordt de patient uitgeschreven. 

*/ Voor de baselinetabel een selectie maken van overleden patienten binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Van overlijden is enkel een jaargetal bekend dus uit datum van diagnose diabetes ook enkel het jaargetal geextraheerd.

* Date and Time Wizard: Jaar_diagnose_DM.
COMPUTE Jaar_diagnose_DM=XDATE.YEAR(Begindatum_Diabetes_alle).
VARIABLE LABELS Jaar_diagnose_DM "Jaar_diagnose_DM".
VARIABLE LEVEL Jaar_diagnose_DM(NOMINAL).
FORMATS Jaar_diagnose_DM(F8.0).
VARIABLE WIDTH Jaar_diagnose_DM(8).
EXECUTE.

*/ Tijd in maanden tussen overlijden en T0 met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

COMPUTE Overleden_T0=(Overlijdensjaar-Jaar_diagnose_DM).
EXECUTE.

*/ Volgende bestand inladen. Namelijk: het EPS bestand (= DataSet2)

PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE="I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS "+
    "analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor "+
    "baseline\EPS_DataSet2.csv"
  /ENCODING='UTF8'
  /DELIMITERS="\t"
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  Extractiedatum AUTO
  Systeem AUTO
  StartDate AUTO
  EndDate AUTO
  PATNR AUTO
  PRAKNR AUTO
  EpisodeID AUTO
  Begindatum AUTO
  dBegindatum AUTO
  Einddatum AUTO
  dEinddatum AUTO
  Mutatiedatum AUTO
  dMutatiedatum AUTO
  ICPC AUTO
  dICPC AUTO
  Omschrijving AUTO
  Episodetype AUTO
  dEpisodetype AUTO
  Actief AUTO
  dActief AUTO
  Attentie AUTO
  dAttentie AUTO
  /MAP.
RESTORE.
CACHE.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

*/ Variabelen welke niet essentieel zijn voor de baselinetabel verwijderd. Namelijk: Systeem, StartDate, EndDate, EpisodeID, (d) Mutatiedatum, (d)Attentie, (d)Mutatiedatum
*/ Dubbele variabelen verwijderd: variabelen met d ervoor behouden omdat SPSS dit beter herkent. 
*/ dMutatiedatum heeft een hogere frequency dan Mutatiedatum, dus dMutatiedatum behouden. Frequency van dActief/Actief, dICPC/ICPC en dActief/Actief gelijk. In de laatste drie gevallen gekozen voor d"..". 
*/ Einddatum bevat relatief weinig gegevens (gecontroleerd in het CSV bestand). In combinatie met het feit dat we ervanuit gaan dat de ICPC chronische ziektes betreffen die geen einddatum hebben, de variabele (d)Einddatum verwijderd. 

DELETE VARIABLES Systeem to Enddate.
DELETE VARIABLES PRAKNR to EpisodeID. 
DELETE VARIABLES Begindatum. 
DELETE VARIABLES Einddatum to dEinddatum. 
DELETE VARIABLES Mutatiedatum to dMutatiedatum.
DELETE VARIABLES ICPC.
DELETE VARIABLES Episodetype to dAttentie.

*/Variabelen gelabeld. 

VARIABLE LABELS PATNR 'Patiëntnummer'.
VARIABLE LABELS dBegindatum 'Startdatum_ICPC_alle'. 
VARIABLE LABELS dICPC 'ICPC'.
VARIABLE LABELS Omschrijving 'Omschrijving episode'.

*/ Datums die nog string zijn ipv date veranderd naar variable type date. Eerst 10 decimals gemaakt anders dan werkt sdate10 niet (10=aantal decimals)
*/ Ook de variabelen die al date type waren naar 10 decimalen gezet om het tijdstip c.q. de uren, minuten en seconden te verwijderen

ALTER TYPE dBegindatum (a10). 
ALTER TYPE dBegindatum (sdate10).
ALTER TYPE Extractiedatum (a10).
ALTER TYPE Extractiedatum (sdate10).

*/ Variabele ICPC uit DataSet2 opgedeeld in individuele ICPC's middels 'recode'
*/ Vervolgens deze individuele ICPC's geselecteerd middels select cases en in een apart bestand gezet middels 'copy to a new dataset'
*/ In de losse bestanden met een individuele ICPC de duplicates verwijderd middels 'identify duplicates' 'define matching cases by PATNR'
*/ Tenslotte de bestanden met ongedupliceerde ICPC codes toegevoegd aan het PAT bestand (DataSet1.) 

*/ Eerste ICPC is Diabetes en dit in een nieuwe dataset gezet genaamd Diabetes_alle 

DATASET ACTIVATE DataSet2. 
RECODE dICPC ('T90'=1) ('T90.01'=1) ('T90.02'=1) (ELSE=0) INTO Diabetes_alle.

DATASET COPY  Diabetes_alle.
DATASET ACTIVATE  Diabetes_alle.
FILTER OFF.
USE ALL.
SELECT IF (Diabetes_alle = 1).
EXECUTE.

*/ In deze Diabetes_alle dataset duplicates geïdentificeerd middels matching cases by PATNR en sort within matching group dBegindatum ("Startdatum_ICPC_all) = datum diagnose registratie
*/ dBegindatum 'primary first' gekozen ipv primary last om te selecteren op de eerste diagnose registratie van DM. 

*/Duplicates verwijderen dmv selecten op primary first. Alle niet-primary first c.q. alle ICPC herhalingen (per patiënte) worden daardoor verwijderd 

DATASET ACTIVATE Diabetes_alle.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) dBegindatum(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele dBegindatum in Diabetes_alle dataset nieuwe naam gegeven om aan te duiden dat deze alleen op Diabetes betrekking heeft. 
*/ PrimaryFirst variabel verwijderd; is na eerdere selectie  op primary first, nu een overbodige variabele geworden aangezien alle niet-primary first hierdoor verwijderd zijn.

RENAME VARIABLES (dBegindatum=Begindatum_Diabetes_alle).
DELETE VARIABLES PrimaryFirst.

*/ PM frequency van Diabetes_alle= 50291

*/ Variabele aanmaken voor leeftijd op T0 (=datum registratie diagnose DM). Leeftijd op T0 = ( Begindatum_Diabetes_alle - Geboortejaar).
*/ Eerst variabele gemaakt voor jaar registratie diagnose DM omdat Geboortejaar enkel een jaar is en niet een volledige datum.
*/ Verderop (na de merge van Diabetes_alle met het PAT bestand een variabele aangemaakt voor leeftijd op baseline). 

* Date and Time Wizard: Jaar_diagnose_diabetes_alle.
COMPUTE Jaar_diagnose_diabetes_alle=XDATE.YEAR(Begindatum_Diabetes_alle).
VARIABLE LABELS Jaar_diagnose_diabetes_alle "Jaar_diagnose_diabetes_alle".
VARIABLE LEVEL Jaar_diagnose_diabetes_alle(NOMINAL).
FORMATS Jaar_diagnose_diabetes_alle(F8.0).
VARIABLE WIDTH Jaar_diagnose_diabetes_alle(8).
EXECUTE.

*/Diabetes_alle zonder duplicates DataSet3 genoemd om deze dataset later weer te kunnen gebruiken. 

DATASET NAME DataSet3 WINDOW=FRONT.

*/ Diabetes_alle unduplicated als eerste toegevoegd aan het PAT (DataSet1) middels merge one to one met PATNR als key variable zodat alle ICPC worden gekoppeld aan het juist PATNR

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet3.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='DataSet3'
  /RENAME (Extractiedatum = d0) 
  /BY PATNR
  /DROP= d0.
EXECUTE.

*/ Variabele aangemaakt voor  Leeftijd op T0 = ( Jaar_diagnose_diabetes_alle - Geboortejaar).

DATASET ACTIVATE DataSet1.
COMPUTE Leeftijd_T0=(Jaar_diagnose_diabetes_alle)  - (Geboortejaar).
EXECUTE.

VARIABLE LABELS Leeftijd_T0 'Leeftijd op baseline'.

*/T90 om te controleren hoeveel patiënten een T90 registratie hebben in het HIS systeem. 

DATASET ACTIVATE DataSet2.
RECODE dICPC ('T90'=1) (ELSE=0) INTO Diabetes_T90.

DATASET COPY  Diabetes_T90.
DATASET ACTIVATE  Diabetes_T90.
FILTER OFF.
USE ALL.
SELECT IF (Diabetes_T90 = 1).
EXECUTE.

*/ In het bestand Diabetes_T90 duplicates geidentificeerd en geselecteerd obv PATNR en dBegindatum met een selectie op PrimaryFirst oftewel de eerste
diagnose registratie. 

* Identify Duplicate Cases.
SORT CASES BY PATNR(A) dBegindatum(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

DELETE VARIABLES PrimaryFirst.
DELETE VARIABLES Diabetes_alle. 
RENAME VARIABLES (dBegindatum=BegindatumT90). 

*/ Diabetes_T90 toegevoegd aan het PAT bestand (DataSet1). 

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Diabetes_T90.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Diabetes_T90'
  /RENAME (Extractiedatum dICPC Omschrijving = d0 d1 d2) 
  /BY PATNR
  /DROP= d0 d1 d2.
EXECUTE.

*/ Variabele Diabetes_T90 bevat nu enkel een 1 als de patient een ICPC code T90 heeft gekregen. Variabele hercoderen zodat deze een binaire uitkomst heeft. 

RECODE Diabetes_T90 (1=1) (ELSE=0) INTO Diabetes_T90_ja_nee.
VARIABLE LABELS  Diabetes_T90_ja_nee 'Diabetes geregistreerd als T90'.
EXECUTE.

*/ Variabele Diabetes_T90 is nu oud/overbodig, dus verwijderd. 

DELETE VARIABLES Diabetes_T90. 

*/ Diabetes_type_1 ICPC's geselecteerd zoals hierboven beschreven voor Diabetes_alle.

DATASET ACTIVATE DataSet2.
RECODE dICPC ('T90.01'=1) (ELSE=0) INTO Diabetes_type_1.

DATASET COPY  Diabetes_type_1.
DATASET ACTIVATE  Diabetes_type_1.
FILTER OFF.
USE ALL.
SELECT IF (Diabetes_type_1 = 1).
EXECUTE.

*/ Duplicates binnen het bestand met type 1 diabetes geidentificeerd en geselecteerd op PrimaryFirst om de eerste diagnose registratie te selecteren. 

* Identify Duplicate Cases.
SORT CASES BY PATNR(A) dBegindatum(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Na de voorgaande selectie op PrimaryFirst bevat het bestand enkel primary cases van type 1, dus de variabele PrimaryFirst is overbodig. Verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Om te verduidelijken dat deze specifieke begindatum hoort bij type 1 diabetes mellitus, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Diabetes_type1). 

*/ Diabetes type 1 toegevoegd aan PAT bestand (DataSet1). 
*/ Om te zorgen dat de merge goed gaat, variabelen die al in het PAT bestand aanwezig zijn verwijderd: Diabetes_alle en Diabetes_T90. 

DELETE VARIABLES Diabetes_alle.
DELETE VARIABLES Diabetes_T90.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Diabetes_type_1.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Diabetes_type_1'
  /RENAME (Extractiedatum dICPC Omschrijving = d0 d1 d2) 
  /BY PATNR
  /DROP= d0 d1 d2.
EXECUTE.

*/ Variabele Diabetes_type_1 bevat enkel een 1 als de patient een ICPC code T90.01 heeft gekregen. Variabele hercoderen zodat deze een binaire uitkomst heeft. 

RECODE Diabetes_type_1 (1=1) (ELSE=0) INTO Diabetes_type_1_ja_nee.
VARIABLE LABELS  Diabetes_type_1_ja_nee 'Diabetes_type_1_ja_nee'.
EXECUTE.

*/ Variabele Diabetes_type_1 is nu oud/overbodig, dus verwijderd. 

DELETE VARIABLES Diabetes_type_1. 
VARIABLE LABELS Diabetes_type_1_ja_nee 'Diabetes type 1'.

*/ Diabetes_type_2

DATASET ACTIVATE DataSet2.
RECODE dICPC ('T90.02'=1) (ELSE=0) INTO Diabetes_type_2.

DATASET COPY  Diabetes_type_2.
DATASET ACTIVATE  Diabetes_type_2.
FILTER OFF.
USE ALL.
SELECT IF (Diabetes_type_2 = 1).
EXECUTE.

*/ Duplicates binnen het bestand met type 2 diabetes geidentificeerd en geselecteerd op PrimaryFirst om de eerste diagnose registratie te selecteren. 

* Identify Duplicate Cases.
SORT CASES BY PATNR(A) dBegindatum(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Bestand met type 2 diabetes bevat nu nog enkel primary cases, dus de variabele PrimaryFirst is overbodig. Verwijderd. 

DELETE VARIABLES PrimaryFirst.

*/ Om te verduidelijken dat deze begindatum hoort bij type 2 diabetes, dBegindatum hernoemd.

RENAME VARIABLES (dBegindatum=Begindatum_Diabetes_type2). 

*/ Diabetes_type_2 toegevoegd aan PAT bestand (DataSet1). 

*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Diabetes_type_2.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Diabetes_type_2'
  /RENAME (Extractiedatum dICPC Omschrijving = d0 d1 d2) 
  /BY PATNR
  /DROP= d0 d1 d2.
EXECUTE.

*/ Variabele Diabetes_type_2 bevat enkel een 1 als de patient een ICPC code T90.02 heeft gekregen. Variabele hercoderen zodat deze een binaire uitkomst heeft. 

RECODE Diabetes_type_2 (1=1) (ELSE=0) INTO Diabetes_type_2_ja_nee.
VARIABLE LABELS  Diabetes_type_2_ja_nee 'Diabetes_type_2_ja_nee'.
EXECUTE.

*/ Variabele Diabetes_type_2 is nu oud/overbodig, dus verwijderd. 

DELETE VARIABLES Diabetes_type_2. 
VARIABLE LABELS Diabetes_type_2_ja_nee 'Diabetes type 2'. 

*/ Hierboven beschreven selectie toegepast voor alle ICPC's 
*/ Echter, voor de baselinetabel ervoor gekozen om te seleteren op ICPC's die 6 maanden voor T0 tot T0 geregistreerd zijn. 
*/ Gestart met de ICPC Onychomycose

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S74.02'=1) (ELSE=0) INTO Onychomycose. 

DATASET COPY  Onychomycose.
DATASET ACTIVATE  Onychomycose.
FILTER OFF.
USE ALL.
SELECT IF (Onychomycose = 1).
EXECUTE.

*/ Per ICPC variabele Begindatum aanpassen naar Begindatum_"betreffende ICPC" zodat voor elke ICPC in het uiteindelijke PAT bestand een begindatum gekoppeld is aan de desbetreffende ICPC.
*/ DataSet1 gemerged met DataSet Onychomycose middels 'merge files, add variables, one to many base on key variables' omdat DataSet Onychomycose nog duplicates bevat en DataSet1 niet. 
*/ Voor de merge wel de variabele ICPC aanpassen anders dan vervangt SPSS de ICPC's in DataSet1 voor de ICPC onychomycose. 

DATASET ACTIVATE Onychomycose. 
RENAME VARIABLES (dBegindatum=Begindatum_Onychomycose). 

*/ Om 'merge' mogelijk te maken eerst duplicates verwijderd. Identify duplicate cases, define matching cases by PATNR, sort within groups by Begindatum_Onychomycose, first case in each group is primary.

* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Onychomycose(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Enkel Primary cases behouden door select cases, if condition is satisfied: PrimaryFirst=1. Delete unselected cases. 
*/ Er hierbij vanuit gegaan dat een patiënt maar een keer een ICPC code krijgt. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer nodig. 

DELETE VARIABLES PrimaryFirst.

*/ Onychomycose welke geen duplicates meer bevat toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1,Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Onychomycose.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Onychomycose'
  /RENAME (Extractiedatum dICPC Omschrijving = d0 d1 d2) 
  /BY PATNR
  /DROP= d0 d1 d2.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van onychomycoses gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose mycose en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenOnychomycose_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenOnychomycose_Diabetes=RND((Begindatum_Onychomycose - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenOnychomycose_Diabetes "Tijd tussen onychomycose en diabetes".
VARIABLE LEVEL  TijdTussenOnychomycose_Diabetes (SCALE).
FORMATS  TijdTussenOnychomycose_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenOnychomycose_Diabetes(5).
EXECUTE.

RECODE TijdTussenOnychomycose_Diabetes (-6 thru 0=1) (ELSE=0) INTO Onychomycose_T0.
VARIABLE LABELS  Onychomycose_T0 'Onychomycose op baseline'.
EXECUTE.

*/ Variabele gemaakt voor onychomycose na baseline (T0). 

COMPUTE Onychomycose_naT0=(Onychomycose=1) AND (TijdTussenOnychomycose_Diabetes > 0).
EXECUTE.

*/ Onychomycose_naT0 omgezet in een binaire variabele. 
*/ Na het voorgaande zijn er twee vergelijkbare variabelen dus Onychomycose_naT0 want die heeft geen binaire uitkomst. 

RECODE Onychomycose_naT0 (1=1) (ELSE=0) INTO OnychomycoseNaT0.
VARIABLE LABELS  OnychomycoseNaT0 'Onychomycose na baseline'.
EXECUTE.

DELETE VARIABLES Onychomycose_naT0.

*/Tinea pedis

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S74.01'=1) (ELSE=0) INTO Tinea_Pedis.

DATASET COPY  Tinea_Pedis.
DATASET ACTIVATE  Tinea_Pedis.
FILTER OFF.
USE ALL.
SELECT IF (Tinea_Pedis = 1).
EXECUTE.

*/ Per ICPC variabele Begindatum aanpassen naar Begindatum_"betreffende ICPC" zodat voor elke ICPC in het uiteindelijke PAT bestand een begindatum gekoppeld is aan de desbetreffende ICPC 

DATASET ACTIVATE Tinea_Pedis.
RENAME VARIABLES (dBegindatum=Begindatum_Tinea_Pedis). 

*/ DataSet Tinea_Pedis toegevoegd aan DataSet1 zodat deze de begindatum van tinea pedis bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand Tinea_Pedis aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Tinea_Pedis.
SORT CASES BY PATNR(A) Begindatum_Tinea_Pedis(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Tinea_Pedis toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Tinea_Pedis.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Tinea_Pedis'
  /RENAME (Extractiedatum dICPC Omschrijving Onychomycose = d0 d1 d2 d3) 
  /BY PATNR
  /DROP= d0 d1 d2 d3.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van tinea pedis gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose tinea pedis en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenTinea_Pedis_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenTinea_Pedis_Diabetes=RND((Begindatum_Tinea_Pedis - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenTinea_Pedis_Diabetes "TijdTussenTinea_Pedis_Diabetes".
VARIABLE LEVEL  TijdTussenTinea_Pedis_Diabetes (SCALE).
FORMATS  TijdTussenTinea_Pedis_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenTinea_Pedis_Diabetes (5).
EXECUTE.

RECODE TijdTussenTinea_Pedis_Diabetes (-6 thru 0=1) (ELSE=0) INTO Tinea_Pedis_T0.
VARIABLE LABELS  Tinea_Pedis_T0 'Tinea pedis op baseline'.
EXECUTE.

*/ Variabele gemaakt voor tinea pedis na T0. 

COMPUTE Tinea_Pedis_naT0=(Tinea_Pedis=1) AND (TijdTussenTinea_Pedis_Diabetes > 0).
EXECUTE.

*/ Tinea_Pedis_naT0 omgezet in een binaire variabele. 
*/ Na het voorgaande zijn er twee vergelijkbare variabelen dus Tinea_Pedis_naT0 want die heeft geen binaire uitkomst. 

RECODE Tinea_Pedis_naT0 (1=1) (ELSE=0) INTO Tinea_PedisNaT0.
VARIABLE LABELS  Tinea_PedisNaT0 'Tinea pedis na baseline'.
EXECUTE.

DELETE VARIABLES Tinea_Pedis_naT0.

*/ Met duplicate analyse gecheckt dat Tinea_Pedis_naT0 geen duplicates meer bevat. 

*/ Variabele gemaakt voor S74.01 (Tinea Pedis) en S74.02 (Onychomycose). 

COMPUTE Voetschimmel_alle=(Onychomycose_ja_nee=1) OR (Tinea_Pedis_ja_nee=1).
EXECUTE.

*/Veneuze insufficiëntie

DATASET ACTIVATE DataSet2.
RECODE dICPC  ('K99.04'=1) (ELSE=0) INTO Veneuze_insufficientie.

DATASET COPY  Veneuze_insufficientie.
DATASET ACTIVATE  Veneuze_insufficientie.
FILTER OFF.
USE ALL.
SELECT IF (Veneuze_insufficientie = 1).
EXECUTE.

RENAME VARIABLES (dBegindatum=Begindatum_Veneuze_insufficientie). 

*/ DataSet Veneuze_insufficientie toegevoegd aan DataSet1 zodat deze de begindatum van tinea pedis bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand Tinea_Pedis aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Veneuze_insufficientie.
SORT CASES BY PATNR(A) Begindatum_Veneuze_insufficientie(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Veneuze_insufficientie toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Veneuze_insufficientie.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Veneuze_insufficientie'
  /RENAME (Extractiedatum dICPC Omschrijving Onychomycose Tinea_Pedis = d0 d1 d2 d3 d4) 
  /BY PATNR
  /DROP= d0 d1 d2 d3 d4.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van veneuze insufficientie gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose veneuze insufficientie en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenVeneuze_insufficientie_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenVeneuze_insufficientie_Diabetes=RND((Begindatum_Veneuze_insufficientie - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenVeneuze_insufficientie_Diabetes "TijdTussenVeneuze_insufficientie_Diabetes".
VARIABLE LEVEL  TijdTussenVeneuze_insufficientie_Diabetes (SCALE).
FORMATS  TijdTussenVeneuze_insufficientie_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenVeneuze_insufficientie_Diabetes (5).
EXECUTE.

RECODE TijdTussenVeneuze_insufficientie_Diabetes (-6 thru 0=1) (ELSE=0) INTO Veneuze_insufficientie_T0.
VARIABLE LABELS  Veneuze_insufficientie_T0 'Veneuze_insufficientie op baseline'.
EXECUTE.

*/ Perifeer arterieel vaatlijden

DATASET ACTIVATE DataSet2.
RECODE dICPC ('K92.01'=1) ('K92'=1) (ELSE=0) INTO Perifeer_arterieel_vaatlijden. 

DATASET COPY  Perifeer_arterieel_vaatlijden.
DATASET ACTIVATE  Perifeer_arterieel_vaatlijden.
FILTER OFF.
USE ALL.
SELECT IF (Perifeer_arterieel_vaatlijden = 1).
EXECUTE.

RENAME VARIABLES (dBegindatum=Begindatum_Perifeer_arterieel_vaatlijden). 

*/ DataSet Perifeer_arterieel_vaatlijden toegevoegd aan DataSet1 zodat deze de begindatum van tinea pedis bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand Perifeer_arterieel_vaatlijden aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Perifeer_arterieel_vaatlijden.
SORT CASES BY PATNR(A) Begindatum_Perifeer_arterieel_vaatlijden(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Veneuze_insufficientie toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Perifeer_arterieel_vaatlijden.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Perifeer_arterieel_vaatlijden'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van perifeer arterieel vaatlijden gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose perifeer arterieel vaatlijlden en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenPerifeer_arterieel_vaatlijden_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenPerifeer_arterieel_vaatlijden_Diabetes=RND((Begindatum_Perifeer_arterieel_vaatlijden - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenPerifeer_arterieel_vaatlijden_Diabetes "TijdTussenPerifeer_arterieel_vaatlijden_Diabetes".
VARIABLE LEVEL  TijdTussenPerifeer_arterieel_vaatlijden_Diabetes (SCALE).
FORMATS  TijdTussenPerifeer_arterieel_vaatlijden_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenPerifeer_arterieel_vaatlijden_Diabetes (5).
EXECUTE.

RECODE TijdTussenPerifeer_arterieel_vaatlijden_Diabetes (-6 thru 0=1) (ELSE=0) INTO Perifeer_arterieel_vaatlijden_T0.
VARIABLE LABELS  Perifeer_arterieel_vaatlijden_T0 'Perifeer arterieel vaatlijden op baseline'.
EXECUTE.

*/ Enkeloedeem

DATASET ACTIVATE DataSet2.
RECODE dICPC ('K07'=1) (ELSE=0)  INTO Enkeloedeem.

DATASET COPY  Enkeloedeem.
DATASET ACTIVATE  Enkeloedeem.
FILTER OFF.
USE ALL.
SELECT IF (Enkeloedeem = 1).
EXECUTE.

RENAME VARIABLES (dBegindatum=Begindatum_Enkeloedeem). 

*/ DataSet Enkeloedeem toegevoegd aan DataSet1 zodat deze de begindatum van enkeloedeem bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand Enkeloedeem aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Enkeloedeem.
SORT CASES BY PATNR(A) Begindatum_Enkeloedeem(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Enkeloedeem toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Enkeloedeem.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Enkeloedeem'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van enkel oedeem gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose enkeloedeem en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenEnkeloedeem_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenEnkeloedeem_Diabetes=RND((Begindatum_Enkeloedeem - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenEnkeloedeem_Diabetes "TijdTussenEnkeloedeem_Diabetes".
VARIABLE LEVEL  TijdTussenEnkeloedeem_Diabetes (SCALE).
FORMATS  TijdTussenEnkeloedeem_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenEnkeloedeem_Diabetes (5).
EXECUTE.

RECODE TijdTussenEnkeloedeem_Diabetes (-6 thru 0=1) (ELSE=0) INTO Enkeloedeem_T0.
VARIABLE LABELS  Enkeloedeem_T0 'Enkeloedeem op baseline'.
EXECUTE.

*/ Psoriasis

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S91'=1) (ELSE=0)  INTO Psoriasis.

DATASET COPY  Psoriasis.
DATASET ACTIVATE  Psoriasis.
FILTER OFF.
USE ALL.
SELECT IF (Psoriasis = 1).
EXECUTE.

*/ Om te verduidelijken dat deze specifieke begindatum hoor bij psoriasis, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Psoriasis). 

*/ DataSet Psoriasis toegevoegd aan DataSet1 zodat deze de begindatum van psoriasis bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Psoriasis.
SORT CASES BY PATNR(A) Begindatum_Psoriasis(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Psoriasis toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Psoriasis.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Psoriasis'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van psoriasis gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose psoriasis en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenPsoriasis_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenPsoriasis_Diabetes=RND((Begindatum_Psoriasis - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenPsoriasis_Diabetes "TijdTussenPsoriasis_Diabetes".
VARIABLE LEVEL  TijdTussenPsoriasis_Diabetes (SCALE).
FORMATS  TijdTussenPsoriasis_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenPsoriasis_Diabetes (5).
EXECUTE.

RECODE TijdTussenPsoriasis_Diabetes (-6 thru 0=1) (ELSE=0) INTO Psoriasis_T0.
VARIABLE LABELS  Psoriasis_T0 'Psoriasis op baseline'.
EXECUTE.

*/Lichen ruber planus 

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S99.06'=1) (ELSE=0) INTO Lichen_ruber_planus.

DATASET COPY  Lichen_ruber_planus.
DATASET ACTIVATE  Lichen_ruber_planus.
FILTER OFF.
USE ALL.
SELECT IF (Lichen_ruber_planus = 1).
EXECUTE.

*/ Om te verduidelijken dat deze specifieke begindatum bij lichen ruber planus hoort, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Lichen_ruber_planus). 

*/ DataSet Lichen_ruber_planus toegevoegd aan DataSet1 zodat deze de begindatum van lichen ruber planus bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

* Identify Duplicate Cases.
DATASET ACTIVATE Lichen_ruber_planus. 
SORT CASES BY PATNR(A) Begindatum_Lichen_ruber_planus(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Lichen_ruber_planus toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Lichen_ruber_planus.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Lichen_ruber_planus'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van lichen ruber planus gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose lichen ruber planus en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenLichen_ruber_planus_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenLichen_ruber_planus_Diabetes=RND((Begindatum_Lichen_ruber_planus - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenLichen_ruber_planus_Diabetes "TijdTussenLichen_ruber_planus_Diabetes".
VARIABLE LEVEL  TijdTussenLichen_ruber_planus_Diabetes (SCALE).
FORMATS  TijdTussenLichen_ruber_planus_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenLichen_ruber_planus_Diabetes (5).
EXECUTE.

RECODE TijdTussenLichen_ruber_planus_Diabetes (-6 thru 0=1) (ELSE=0) INTO Lichen_ruber_planus_T0.
VARIABLE LABELS  Lichen_ruber_planus_T0 'Lichen ruber planus op baseline'.
EXECUTE.

*/ Eczeem 

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S88'=1) (ELSE=0)  INTO Eczeem.

DATASET COPY  Eczeem.
DATASET ACTIVATE  Eczeem.
FILTER OFF.
USE ALL.
SELECT IF (Eczeem = 1).
EXECUTE.

*/ Om te verduidelijken dat deze specifieke begindatum hoort bij eczeem, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Eczeem). 

*/ DataSet Eczeem toegevoegd aan DataSet1 zodat deze de begindatum van eczeem bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

* Identify Duplicate Cases.

DATASET ACTIVATE Eczeem.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Eczeem(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.


*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Eczeem toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Eczeem.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE= 'Eczeem'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van eczeem gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose eczeem en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenEczeem_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenEczeem_Diabetes=RND((Begindatum_Eczeem - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenEczeem_Diabetes "TijdTussenEczeem_Diabetes".
VARIABLE LEVEL  TijdTussenEczeem_Diabetes (SCALE).
FORMATS  TijdTussenEczeem_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenEczeem_Diabetes (5).
EXECUTE.

RECODE TijdTussenEczeem_Diabetes (-6 thru 0=1) (ELSE=0) INTO Eczeem_T0.
VARIABLE LABELS  Eczeem_T0 'Eczeem op baseline'.
EXECUTE.

*/ Variabele gemaakt voor huidaandoening en huidaandoening op baseline welke bestaat uit psoriasis of lichen ruber planus of eczeem. 

DATASET ACTIVATE DataSet1.
COMPUTE Huidaandoening_T0=(Psoriasis_T0 = 1) OR  (Lichen_ruber_planus_T0 = 1) OR (Eczeem_T0 = 1).
EXECUTE.

COMPUTE Huidaandoening=(Psoriasis_ja_nee = 1) OR  (Lichen_ruber_planus_ja_nee = 1) OR (Eczeem_ja_nee = 1).
EXECUTE.
 
*/ Neuropathie 

DATASET ACTIVATE DataSet2.
RECODE dICPC ('N94'=1) ('N94.02'=1) (ELSE=0) INTO Neuropathie.

DATASET COPY  Neuropathie.
DATASET ACTIVATE  Neuropathie.
FILTER OFF.
USE ALL.
SELECT IF (Neuropathie = 1).
EXECUTE.

*/ Om te verduidelijken dat deze specifieke begindatum hoort bij neuropathie, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Neuropathie). 

*/ DataSet Neuropathie toegevoegd aan DataSet1 zodat deze de begindatum van neuropathie bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Neuropathie.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Neuropathie(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.


*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Neuropathie toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Neuropathie.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE= 'Neuropathie'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van neuropathie gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose neuropathie en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenNeuropathie_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenNeuropathie_Diabetes=RND((Begindatum_Neuropathie - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenNeuropathie_Diabetes "TijdTussenNeuropathie_Diabetes".
VARIABLE LEVEL  TijdTussenNeuropathie_Diabetes (SCALE).
FORMATS  TijdTussenNeuropathie_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenNeuropathie_Diabetes (5).
EXECUTE.

RECODE TijdTussenNeuropathie_Diabetes (-6 thru 0=1) (ELSE=0) INTO Neuropathie_T0.
VARIABLE LABELS  Neuropathie_T0 'Neuropathie op baseline'.
EXECUTE.

*/ Tabaksmisbruik 

DATASET ACTIVATE DataSet2.
RECODE dICPC  ('P17'=1) (ELSE=0)  INTO Tabaksmisbruik.

DATASET COPY  Tabaksmisbruik.
DATASET ACTIVATE  Tabaksmisbruik.
FILTER OFF.
USE ALL.
SELECT IF (Tabaksmisbruik = 1).
EXECUTE.

*/ Om te verduidelijken dat deze specifieke begindatum bij tabaksmisbruik, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Tabaksmisbruik). 

*/ DataSet Tabaksmisbruik toegevoegd aan DataSet1 zodat deze de begindatum van Tabaksmisbruik bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Tabaksmisbruik.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Tabaksmisbruik(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.


*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Tabaksmisbruik toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Tabaksmisbruik.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE= 'Tabaksmisbruik'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van Tabaksmisbruik gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose Tabaksmisbruik en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenTabaksmisbruik_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenTabaksmisbruik_Diabetes=RND((Begindatum_Tabaksmisbruik - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenTabaksmisbruik_Diabetes "TijdTussenTabaksmisbruik_Diabetes".
VARIABLE LEVEL  TijdTussenTabaksmisbruik_Diabetes (SCALE).
FORMATS  TijdTussenTabaksmisbruik_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenTabaksmisbruik_Diabetes (5).
EXECUTE.

RECODE TijdTussenTabaksmisbruik_Diabetes (-6 thru 0=1) (ELSE=0) INTO Tabaksmisbruik_T0.
VARIABLE LABELS  Tabaksmisbruik_T0 'Tabaksmisbruik op baseline'.
EXECUTE.

*/ Variabele aangemaakt voor tabaksmisbruik na T0.

COMPUTE Tabaksmisbruik_NaT0=(TijdTussenTabaksmisbruik_Diabetes  > 0).
EXECUTE.

*/Unguis incarnatus 

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S94.01'=1) (ELSE=0) INTO Unguis_incarnatus.

DATASET COPY  Unguis_incarnatus.
DATASET ACTIVATE  Unguis_incarnatus.
FILTER OFF.
USE ALL.
SELECT IF (Unguis_incarnatus = 1).
EXECUTE.

*/ Om te verduidelijken dat deze begindatum bij unguis incarnatus hoort, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Unguis_incarnatus). 

*/ DataSet Tabaksmisbruik toegevoegd aan DataSet1 zodat deze de begindatum van Tabaksmisbruik bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Unguis_incarnatus.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Unguis_incarnatus(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Unguis_incarnatus toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Unguis_incarnatus.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE= 'Unguis_incarnatus'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van Unguis_incarnatus gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose Unguis_incarnatus en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenUnguis_incarnatus_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenUnguis_incarnatus_Diabetes=RND((Begindatum_Unguis_incarnatus - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenUnguis_incarnatus_Diabetes "TijdTussenUnguis_incarnatus_Diabetes".
VARIABLE LEVEL  TijdTussenUnguis_incarnatus_Diabetes (SCALE).
FORMATS  TijdTussenUnguis_incarnatus_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenUnguis_incarnatus_Diabetes (5).
EXECUTE.

RECODE TijdTussenUnguis_incarnatus_Diabetes (-6 thru 0=1) (ELSE=0) INTO Unguis_incarnatus_T0.
VARIABLE LABELS  Unguis_incarnatus_T0 'Unguis incarnatus op baseline'.
EXECUTE.

*/ Variabele gemaakt voor unguis incarnatus na baseline (T0). 

COMPUTE Unguis_incarnatus_naT0=(Unguis_incarnatus=1) AND (TijdTussenUnguis_incarnatus_Diabetes > 0).
EXECUTE.

*/ Ulcus

DATASET ACTIVATE DataSet2.
RECODE dICPC  ('S97.03'=1) ('S97.01'=1) ('S97'=1) (ELSE=0) INTO Ulcus.

DATASET COPY  Ulcus.
DATASET ACTIVATE  Ulcus.
FILTER OFF.
USE ALL.
SELECT IF (Ulcus = 1).
EXECUTE.

*/ Om te verduidelijken dat deze begindatum bij ulcus hoort, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Ulcus). 

*/ DataSet Ulcus toegevoegd aan DataSet1 zodat deze de begindatum van Ulcus bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Ulcus.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Ulcus(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Ulcus toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Ulcus.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE= 'Ulcus'
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van Ulcus gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose Unguis_incarnatus en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenUlcus_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenUlcus_Diabetes=RND((Begindatum_Ulcus - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenUlcus_Diabetes "TijdTussenUlcus_Diabetes".
VARIABLE LEVEL  TijdTussenUlcus_Diabetes (SCALE).
FORMATS  TijdTussenUlcus_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenUlcus_Diabetes (5).
EXECUTE.

RECODE TijdTussenUlcus_Diabetes (-6 thru 0=1) (ELSE=0) INTO Ulcus_T0.
VARIABLE LABELS  Ulcus_T0 'Ulcus op baseline'.
EXECUTE.

*/ Variabele gemaakt voor ulcus na baseline (T0). 

COMPUTE Ulcus_naT0=(Ulcus=1) AND (TijdTussenUlcus_Diabetes > 0).
EXECUTE.

*/ Ulcus_naT0 omgezet in een binaire variabele. 
*/ Na het voorgaande zijn er twee vergelijkbare variabelen dus Ulcus_naT0 want die heeft geen binaire uitkomst. 

RECODE Ulcus_naT0 (1=1) (ELSE=0) INTO UlcusNaT0.
VARIABLE LABELS  UlcusNaT0 'Ulcus na baseline'.
EXECUTE.

DELETE VARIABLES Ulcus_naT0.

*/Erysipelas 

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S76.01'=1) ('S76'=1) (ELSE=0) INTO Erysipelas.

DATASET COPY  Erysipelas.
DATASET ACTIVATE  Erysipelas.
FILTER OFF.
USE ALL.
SELECT IF (Erysipelas = 1).
EXECUTE.

*/ Om te verduidelijken dat deze specifieke begindatum bij erysipelas hoort, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Erysipelas). 

DATASET ACTIVATE DataSet2.

*/ DataSet Ulcus toegevoegd aan DataSet1 zodat deze de begindatum van Ulcus bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Erysipelas .
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Erysipelas (A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Erysipelas toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Erysipelas .
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE= 'Erysipelas '
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van erysipelas gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose erysipelas en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenErysipelas_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenErysipelas_Diabetes=RND((Begindatum_Erysipelas - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenErysipelas_Diabetes "TijdTussenErysipelas_Diabetes".
VARIABLE LEVEL  TijdTussenErysipelas_Diabetes (SCALE).
FORMATS  TijdTussenErysipelas_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenErysipelas_Diabetes (5).
EXECUTE.

RECODE TijdTussenErysipelas_Diabetes (-6 thru 0=1) (ELSE=0) INTO Erysipelas_T0.
VARIABLE LABELS  Erysipelas_T0 'Erysipelas op baseline'.
EXECUTE.

*/ Variabele gemaakt voor Erysipelas na baseline (T0). 

COMPUTE Erysipelas_naT0=(Erysipelas=1) AND (TijdTussenErysipelas_Diabetes > 0).
EXECUTE.

*/ Cellulitis

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S10.03'=1) (ELSE=0) INTO Cellulitis.

DATASET COPY  Cellulitis.
DATASET ACTIVATE  Cellulitis.
FILTER OFF.
USE ALL.
SELECT IF (Cellulitis = 1).
EXECUTE.

*/ Om te verduidelijken dat deze specifieke begindatum bij Cellulitis hoort, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Cellulitis). 

*/ DataSet Ulcus toegevoegd aan DataSet1 zodat deze de begindatum van Ulcus bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Cellulitis .
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Cellulitis (A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Cellulitis toegevoegd aan DataSet1. 
*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Cellulitis .
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE= 'Cellulitis '
  /RENAME (dICPC Omschrijving = d0 d1) 
  /BY PATNR
  /DROP= d0 d1.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van cellulitis gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose Cellulitis_complicatie  en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenCellulitis_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenCellulitis_Diabetes=RND((Begindatum_Cellulitis - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenCellulitis_Diabetes "TijdTussenCellulitis_Diabetes".
VARIABLE LEVEL  TijdTussenCellulitis_Diabetes (SCALE).
FORMATS  TijdTussenCellulitis_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenCellulitis_Diabetes (5).
EXECUTE.

RECODE TijdTussenCellulitis_Diabetes (-6 thru 0=1) (ELSE=0) INTO Cellulitis_T0.
VARIABLE LABELS  Cellulitis_T0 'Cellulitis op baseline'.
EXECUTE.

*/ Variabele gemaakt voor cellulitis na baseline (T0). 

COMPUTE Cellulitis_naT0=(Cellulitis=1) AND (TijdTussenCellulitis_Diabetes > 0).
EXECUTE.

*/ Paronychia/panaritium.

DATASET ACTIVATE DataSet2.
RECODE dICPC ('S09.01'=1) ('S09.02'=1) ('S09'=1) (ELSE=0) INTO Paronychia_panaritium.

*/ PM: analyze descriptive statistics frequencies laat zien dat de codes S09.01 en S09.02 niet geregistreerd zijn. Enkel de generieke code S09 (lokale infectie vinger/teen/paronychia).

DATASET COPY  Paronychia_panaritium.
DATASET ACTIVATE  Paronychia_panaritium.
FILTER OFF.
USE ALL.
SELECT IF (Paronychia_panaritium = 1).
EXECUTE.

*/ Om te verduidelijken dat deze specifieke begindatum bij Paronychia_panaritium hoort, dBegindatum hernoemd. 

RENAME VARIABLES (dBegindatum=Begindatum_Paronychia_panaritium). 

*/ DataSet Paronychia_panaritium toegevoegd aan DataSet1 zodat deze de begindatum van Paronychia_panaritium bevat. Echter zie volgende: 
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Paronychia_panaritium.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Begindatum_Paronychia_panaritium(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ SPSS neemt de variabelen Diabetes_alle, Diabetes_T9 en Diabetes_type_1, Diabetes_type_2 nogmaals mee. Niet nodig, dus verwijderd. 

DELETE VARIABLES Diabetes_alle. 
DELETE VARIABLES Diabetes_T90.
DELETE VARIABLES Diabetes_type_1.
DELETE VARIABLES Diabetes_type_2.

*/ Paronychia_panaritium toegevoegd aan DataSet1. 

SORT CASES BY PATNR.
DATASET ACTIVATE Paronychia_panaritium.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Paronychia_panaritium'
  /RENAME (Extractiedatum dICPC Omschrijving = d0 d1 d2) 
  /BY PATNR
  /DROP= d0 d1 d2.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van Paronychia_panaritium gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose Paronychia_panaritium en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenParonychia_panaritium_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenParonychia_panaritium_Diabetes=RND((Begindatum_Paronychia_panaritium - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenParonychia_panaritium_Diabetes "TijdTussenParonychia_panaritium_Diabetes".
VARIABLE LEVEL  TijdTussenParonychia_panaritium_Diabetes (SCALE).
FORMATS  TijdTussenParonychia_panaritium_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenParonychia_panaritium_Diabetes (5).
EXECUTE.

RECODE TijdTussenParonychia_panaritium_Diabetes (-6 thru 0=1) (ELSE=0) INTO Paronychia_panaritium_T0.
VARIABLE LABELS  Paronychia_panaritium_T0 'Paronychia_panaritium op baseline'.
EXECUTE.

*/ Variabele gemaakt voor Paronychia_panaritium na baseline (T0). 

DATASET ACTIVATE dataset1. 
COMPUTE Paronychia_panaritium_naT0=(Paronychia_panaritium=1) AND (TijdTussenParonychia_panaritium_Diabetes > 0).
EXECUTE.

*/ Voor de 'outcome analyses' moeten de uitkomst en risicofactoren een binaire uitkomst hebben. 
*/ Nu hebben sommige nog enkel een 1. Gerecodeerd naar 0/1 middels recode into same variable 

DATASET ACTIVATE DataSet1.
RECODE Onychomycose Tinea_Pedis Veneuze_insufficientie Perifeer_arterieel_vaatlijden Enkeloedeem 
    Psoriasis Lichen_ruber_planus Eczeem Neuropathie Tabaksmisbruik Unguis_incarnatus Ulcus Erysipelas 
    Cellulitis Paronychia_panaritium (1=1) (ELSE=0).
EXECUTE.

DATASET ACTIVATE DataSet1.
RECODE OnychomycoseNaT0 Tinea_PedisNaT0 Unguis_incarnatus_naT0 UlcusNaT0 Erysipelas_naT0 
    Cellulitis_naT0 Paronychia_panaritium_naT0 (1=1) (ELSE=0).
EXECUTE.

*/ Variabele gemaakt voor infectieuze complicatie (bestaande uit erysipelas, cellulitis en paronychia/panaritium).

DATASET ACTIVATE DataSet1. 
COMPUTE Infectieuze_complicatie=(Erysipelas= 1) OR (Cellulitis= 1) OR (Paronychia_panaritium=1).
EXECUTE.

*/ Variabele gemaakt voor infectieuze complicatie op baseline: Infectieuze_complicatie_T0.

COMPUTE Infectieuze_complicatie_T0=(Cellulitis_T0 = 1) OR (Erysipelas_T0 = 1) OR (Paronychia_panaritium_T0=1).
EXECUTE.

COMPUTE Infectieuze_complicatie_naT0=(Erysipelas_naT0=1) OR (Cellulitis_naT0=1) OR (Paronychia_panaritium_naT0=1) .
EXECUTE.

*/Bestand met verrichtingen VER (=DataSet4). 

PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE="I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS "+
    "analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor "+
    "baseline\VER_DataSet4.csv"
  /ENCODING='UTF8'
  /DELIMITERS="\t"
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  PATNR AUTO
  Extractiedatum AUTO
  Systeem AUTO
  StartDate AUTO
  EndDate AUTO
  OrganisatieID AUTO
  PseudoPatientID AUTO
  EpisodeID AUTO
  Datum AUTO
  dDatum AUTO
  Tijdstip AUTO
  dTijdstip AUTO
  Verrichtingcode AUTO
  Vektiscode AUTO
  dVektiscode AUTO
  NHGNummer AUTO
  dNHGNummer AUTO
  NHGMemo AUTO
  dNHGMemo AUTO
  Omschrijving AUTO
  Bedrag AUTO
  dBedrag AUTO
  VerrichtingICPC AUTO
  dVerrichtingICPC AUTO
  EpisodeICPC AUTO
  dEpisodeICPC AUTO
  /MAP.
RESTORE.
CACHE.
EXECUTE.
DATASET NAME DataSet4 WINDOW=FRONT.


*/ Dubbele variabelen verwijderd: enkel met d ervoor behouden
*/ Tevens overbodige variabelen verwijderd; (d)EpisodeICPC welke geen data bevat (enkel missing). Tijdstip van verrichting is niet relevant. 
*/ Om het bestand te comprimeren ook de variabelen Extractiedatum, Systeem, Enddate en Startdate verwijderd.  
*/ Iedere verrichting heeft een bij behorende Vektiscode, NHGNummer en NHGMemo. Bestand in gedeeld obv Vektiscode.

DELETE VARIABLES Extractiedatum to Datum.
DELETE VARIABLES Tijdstip to dTijdstip. 
DELETE VARIABLES Vektiscode. 
DELETE VARIABLES NHGNummer. 
DELETE VARIABLES NHGMemo. 
DELETE VARIABLES Bedrag to dEpisodeICPC.

*/Variabelen gelabeld 

VARIABLE LABELS PATNR 'Patiëntnummer'.
VARIABLE LABELS dDatum 'DatumVerrichting'. 
VARIABLE LABELS dNHGMemo 'TypeVerrichting'. 
VARIABLE LABELS Verrichtingcode 'CodeVerrichting'. 

*/ Variabele dDatum veranderd naar 10 decimalen (om alle uren, minuten en seconden eruit te halen die toch allemaal op 0 staan).
*/ Vervolgen dDatum omgezet in variale type 'date' in plaats van 'string'.

ALTER TYPE dDatum (a10).
ALTER TYPE dDatum (sdate10).

*/ Vektiscode 13015= Ambulante compressie bij ulcus crusis= bevestiging van aanwezigheid ulcus crusis. 
*/ dNHGMemo COM= ambulante compressietherapie bij ulcus cruris. 
*/ Patient met de variabele 13015 als vektiscode heeft ook de NHGcode COM. Een van de twee genomen om een de variabele Ulcus_cruris te maken. 
*/ Declaratie verrichtingen gericht op modernisering en innovatie= vektiscode 30180

DATASET ACTIVATE DataSet4.
RECODE dVektiscode (13015=1)  (ELSE=0) INTO Ulcus_cruris.

DATASET COPY  Ulcus_cruris.
DATASET ACTIVATE  Ulcus_cruris.
FILTER OFF.
USE ALL.
SELECT IF (Ulcus_cruris= 1).
EXECUTE.

*/ Om te verduidelijken dat de datum van verrichting specifiek hoort bij ulcus cruris, dDatum hernoemd.

RENAME VARIABLES (dDatum=DatumVanVerrichting_Ulcus_cruris). 

*/ DataSet Ulcus_cruris toegevoegd aan DataSet1 zodat deze de begindatum van Ulcus cruris bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

* Identify Duplicate Cases

SORT CASES BY PATNR(A) DatumVanVerrichting_Ulcus_cruris(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Ulcus_cruris toegevoegd aan DataSet1. 

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Ulcus_cruris.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Ulcus_cruris'
  /RENAME (Omschrijving = d0) 
  /BY PATNR
  /DROP= d0.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van Ulcus_cruris gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose Ulcus_cruris  en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenUlcus_cruris_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenUlcus_cruris_Diabetes=RND((DatumVanVerrichting_Ulcus_cruris - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenUlcus_cruris_Diabetes "TijdTussenUlcus_cruris_Diabetes".
VARIABLE LEVEL  TijdTussenUlcus_cruris_Diabetes (SCALE).
FORMATS  TijdTussenUlcus_cruris_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenUlcus_cruris_Diabetes (5).
EXECUTE.

RECODE TijdTussenUlcus_cruris_Diabetes (-6 thru 0=1) (ELSE=0) INTO Ulcus_cruris_T0.
VARIABLE LABELS  Ulcus_cruris_T0 'Ulcus_cruris op baseline'.
EXECUTE.

*/ Variabele gemaakt voor ulcus cruris na baseline (T0). 

COMPUTE Ulcus_cruris_naT0=(Ulcus_cruris=1) AND (TijdTussenUlcus_cruris_Diabetes > 0).
EXECUTE.

*/ PM to self: Analyze descriptive statistics frequencies laat zien dat er 167 patienten zijn met zowel een ulcus als ambulante compressie hiervoor. 

*/ Chirurgische ingreep (eerstelijn)

*/ Analyse descriptive statistics laat zien dat het bestand met verrichtingen met name 13012 chirurgie bevat.
*/ Vektiscode 13012= overige segment 1 verrichtingen. Voor deze studie is uit dit segment het meest relevant: complexe wondbehandleling en nagelchirurgie.  
*/ dNHGMemo CHIRS3= chirurgie segment 3. Segment 3 richt zich op declaratiemogelijkheden van daadwerkelijk behaalde, eerder afgesproken uitkomsten binnen het S1 en S2-segment en voor het stimuleren van vernieuwing.

DATASET ACTIVATE DataSet4. 
RECODE dVektiscode (13012=1) (ELSE=0) INTO Chirurgische_ingreep.

DATASET ACTIVATE DataSet4.
DATASET COPY  Chirurgische_ingreep.
DATASET ACTIVATE  Chirurgische_ingreep.
FILTER OFF.
USE ALL.
SELECT IF (Chirurgische_ingreep = 1).
EXECUTE.

*/ Om te verduidelijken dat deze datum van verrichting bij Chirurgische_ingreep hoort, dDatum hernoemd.

RENAME VARIABLES (dDatum=Datum_Chirurgische_ingreep). 

*/ DataSet Chirurgische_ingreep toegevoegd aan DataSet1 zodat deze de begindatum van Ulcus cruris bevat.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE Chirurgische_ingreep.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Datum_Chirurgische_ingreep(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderen middels selectie op PrimaryFirst, delete unselected cases. 

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ Variabele PrimaryFirst niet meer essentieel dus verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ Chirurgische_ingreep toegevoegd aan DataSet1. 

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE Chirurgische_ingreep.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Chirurgische_ingreep'
  /RENAME (Omschrijving = d0) 
  /BY PATNR
  /DROP= d0.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van Chirurgische_ingreep gediagnosticeerd binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose Chirurgische_ingreep en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenChirurgische_ingreep_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenChirurgische_ingreep_Diabetes=RND((Datum_Chirurgische_ingreep - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenChirurgische_ingreep_Diabetes "TijdTussenChirurgische_ingreep_Diabetes".
VARIABLE LEVEL  TijdTussenChirurgische_ingreep_Diabetes (SCALE).
FORMATS  TijdTussenChirurgische_ingreep_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenChirurgische_ingreep_Diabetes (5).
EXECUTE.

RECODE TijdTussenChirurgische_ingreep_Diabetes (-6 thru 0=1) (ELSE=0) INTO Chirurgische_ingreep_T0.
VARIABLE LABELS  Chirurgische_ingreep_T0 'Chirurgische ingreep op baseline'.
EXECUTE.

*/ Variabele gemaakt voor Chirurgische_ingreep na baseline (T0). 

COMPUTE Chirurgische_ingreep_naT0=(Chirurgische_ingreep =1) AND (TijdTussenChirurgische_ingreep_Diabetes > 0).
EXECUTE.

*/ Zoals hierboven beschreven: voor de 'outcome analyses' moeten de uitkomsten een binaire uitkomst hebben. 
*/ Nu hebben sommige nog enkel een 1. Gerecodeerd naar 0/1 middels recode into same variable. 

DATASET ACTIVATE DataSet1.
RECODE Ulcus_cruris_naT0 Ulcus_Totaal_NaT0 Chirurgische_ingreep Chirurgische_ingreep_naT0 (1=1) (ELSE=0).
EXECUTE.

*/ Bestand VW (=verwijzingen) geopend als DataSet16 (omdat deze later is toegevoegd 16 genoemd). 

PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE="I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS "+
    "analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor "+
    "baseline\VW_DataSet5.csv"
  /ENCODING='UTF8'
  /DELIMITERS="\t"
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  Extractiedatum AUTO
  Systeem AUTO
  StartDate AUTO
  EndDate AUTO
  PATNR AUTO
  PRAKNR AUTO
  EpisodeID AUTO
  Datum AUTO
  dDatum AUTO
  Richting AUTO
  dRichting AUTO
  CorrespondentieICPC AUTO
  dCorrespondentieICPC AUTO
  EpisodeICPC AUTO
  dEpisodeICPC AUTO
  Specialisme AUTO
  dSpecialisme AUTO
  /MAP.
RESTORE.
CACHE.
EXECUTE.
DATASET NAME DataSet16 WINDOW=FRONT.

*/ Dubbele variabelen verwijderd: enkel met d ervoor behouden
*/ Zoals hierboven reeds beschreven, ook hier verwijderd: Extractiedatum, Systeem, Startdate, Enddate, PRAKNR.
*/ EpisodeID,(d)Richting, (d)CorrespondentieICPC (laatste zegt hetzelfde als EpisodeICPC). 
*/ EpisodeID als numerieke variabele bewaard om aan te kunnen geven of iemand wel (1) of niet (0) is verwezen. 

DELETE VARIABLES Extractiedatum to EndDate.
DELETE VARIABLES PRAKNR.
DELETE VARIABLES Datum. 
DELETE VARIABLES Richting to dCorrespondentieICPC.
DELETE VARIABLES EpisodeICPC.
DELETE VARIABLES Specialisme. 

*/ Het bestand VW (DataSet16) bestaat enkel uit verwijzingen met EpisodeICPC diabetes (T90, T90.01 of T90.02). 
*/ EpisodeICPC op basis v.h. bovenstaande niet meer nodig, dus verwijderd. 

DELETE VARIABLES dEpisodeICPC.

*/ Voor de leesbaarheid het format van de variabele DatumVerwijzing aangepast.

DATASET ACTIVATE DataSet16.
ALTER TYPE dDatum (sdate). 

*/ dDatum hernoemd tot datum van verwijzing. 

RENAME VARIABLES (dDatum=DatumVerwijzing). 

*/ DataSet16 (verwijzingen) toegevoegd aan DataSet1.
*/ Merge files, add variables werkt niet als er nog duplicates in het bestand  aanwezig zijn, dus eerst duplicates verwijderd.
*/ Duplicate analyse o.b.v. PATNR, binnen groepen selecteren op dBegindatum Primary First. 

DATASET ACTIVATE DataSet16.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) DatumVerwijzing(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

DELETE VARIABLES PrimaryFirst. 

*/ Aangepaste DataSet16 toegevoegd aan DataSet1. 

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet16.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='DataSet16'
  /BY PATNR.
EXECUTE.

*/ Variabele gemaakt: verwezen naar tweede lijn ja/nee.

DATASET ACTIVATE DataSet1.
RECODE EpisodeID (1 thru Highest=1) (ELSE=0) INTO Verwezen_tweedelijn.
VARIABLE LABELS  Verwezen_tweedelijn 'Verwezen_tweedelijn'.
EXECUTE.

*/ Voor de baselinetabel een selectie maken van verwijzing binnen een range van 6 maanden voor de diagnose diabetes tot de diagnose diabetes (T0). 
*/ Tijd in maanden tussen diagnose Verwezen_tweedelijn en T0. Met een max van 6 maanden voor diagnose tot T0 (=moment van diagnose DM). Aantal maanden afgerond naar een heel getal (round to integer). 

* Date and Time Wizard: TijdTussenVerwijzing_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenVerwijzing_Diabetes=RND((DatumVerwijzing - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS TijdTussenVerwijzing_Diabetes "TijdTussenVerwijzing_Diabetes".
VARIABLE LEVEL  TijdTussenVerwijzing_Diabetes (SCALE).
FORMATS  TijdTussenVerwijzing_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenVerwijzing_Diabetes (5).
EXECUTE.

RECODE TijdTussenVerwijzing_Diabetes (-6 thru 0=1) (ELSE=0) INTO Verwijzing_T0.
VARIABLE LABELS  Verwijzing_T0 'Verwijzing op baseline'.
EXECUTE.

*/ Variabele gemaakt voor Verwijzing na baseline (T0). 

COMPUTE Verwijzing_naT0=(Verwezen_tweedelijn =1) AND (TijdTussenVerwijzing_Diabetes > 0).
EXECUTE.

*/ Ulcus, ulcus cruris, infectieuze complicatie, chirurgische ingreep en verwijzing zijn een vorm van complicatie. 
*/ Verschillende variabelen voor de categoriën van complicaties: ulcus (cruris); infectieuze complicatie; complicatie anderzins (= unguis incarnatus & verwijzing of verrichting). 

*/ Variabele gemaakt voor complicatie 'other type'/anderzins (niet ulceratief, niet infectieus) op baseline. 

COMPUTE Complicatie_anderzins_T0=(Unguis_incarnatus_T0=1) OR (Chirurgische_ingreep_T0=1) OR 
    (Verwijzing_T0=1).
EXECUTE.

COMPUTE Complicatie_anderzins_naT0=(Unguis_incarnatus_NaT0=1) OR (Chirurgische_ingreep_NaT0 = 1) OR (Verwijzing_naT0 = 1).
EXECUTE.

*/ Variabele gemaakt voor Complicatie_enige_vorm_T0.

COMPUTE Complicatie_enige_vorm_T0=(Infectieuze_complicatie_T0=1) OR (Complicatie_anderzins_T0=1) OR (Ulcus_Totaal_T0=1).
EXECUTE.

*/ Variabele gemaakt voor Complicatie_enige_vorm_NaT0

COMPUTE Complicatie_enige_vorm_NaT0=(Infectieuze_complicatie_naT0=1) OR (Complicatie_anderzins_naT0 = 1) OR (Ulcus_Totaal_NaT0 = 1).
EXECUTE.

*/ Hierna volgt de Syntax voor het toevoegen van de verschillende soorten medicatie.
*/ Stap 1: alle losse bestanden ingeladen in SPSS dan opgeslagen zodat ze niet steeds ingeladen hoeven te worden, want dit duurt erg lang. 
*/ Ingeladen middels file import data csv data vanuit kopie files henk (MED1DataSet5; MED2DataSet6; MED3DataSet7). 
*/ Ingeladen bestanden opgeslagen en deze hieronder geimporteerd. 

*/ CSV bestand MED1 (=DataSet5) opgeslagen als MED1_onaangepast_15-08 en vanuit daar geopend zodat het laden minder lang duurt.  

GET
  FILE='I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS '+
    'analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor '+
    'baseline\MED1_onaangepast_15-08.sav'.
DATASET NAME DataSet5 WINDOW=FRONT.

*/ Stopdatum verwijderd want deze variabele bevat geen gegevens, enkel missing. EpisodeICPC ook verwijderd want deze geeft dezelfde informatie als VoorschriftICPC. 
*/ Indien variabelen die dubbel zijn de variabele met een d ervoor behouden. 
*/ Niet essentiele variabelen verwijderd uit MED1 om het bestand te comprimeren zodat het bij de andere medicatie files kan worden toegevoegd. 

DATASET ACTIVATE DataSet5.
DELETE VARIABLES Extractiedatum to EndDate.
DELETE VARIABLES PRAKNR to Voorschrijfdatum.
DELETE VARIABLES Einddatum to dGPK. 
DELETE VARIABLES dSHB to dSpecialisme.

*/ Width van dVoorschrijfdatum aangepast 
*/ SPSS heeft dVoorschrijdatum omgezet in variabel type String. Voor de onderstaande opdracht variable type van dVoorschrijfdatum weer omgezet in Date. 

ALTER TYPE dVoorschrijfdatum (a10). 
ALTER TYPE dVoorschrijfdatum (sdate10). 

*/ Om DataSet5 te verkleinen duplicates verwijderd. Duplicates geselecteerd obv PATNR, binnen groep geselecteerd op dVoorschrijfdatum First=Primary. 

DATASET ACTIVATE DataSet5.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) dVoorschrijfdatum(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderd middels select cases, if condition is satisfied PrimaryFirst=1, delete unselected cases.

Dataset activate DataSet5. 
FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ DataSet5 bestaat nu enkel nog uit primary cases. PrimaryFirst is voor alle patienten 1, dus variabele PrimaryFirst verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ CSV Bestand MED2 (=DataSet6) opgeslagen als MED2_onaangepast_16-09 en vanuit daar geopend zodat het laden minder lang duurt.  

GET
  FILE='I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS '+
    'analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor '+
    'baseline\MED2_onaangepast_16-09.sav'.
DATASET NAME DataSet6 WINDOW=FRONT.

*/ Zoals hiervoor reeds beschreven de volgende variabelen verwijderd: 

DATASET ACTIVATE DataSet6.
DELETE VARIABLES Extractiedatum to EndDate.
DELETE VARIABLES PRAKNR to Voorschrijfdatum.
DELETE VARIABLES Einddatum to dGPK. 
DELETE VARIABLES dSHB to dSpecialisme.

*/ Om DataSet6 te verkleinen duplicates verwijderd. Duplicates geselecteerd obv PATNR, binnen groep geselecteerd op dVoorschrijfdatum First=Primary. 

DATASET ACTIVATE DataSet6.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) dVoorschrijfdatum(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderd middels select cases, if condition is satisfied PrimaryFirst=1, delete unselected cases.

Dataset activate DataSet6. 
FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ DataSet6 bestaat nu enkel nog uit primary cases. PrimaryFirst is voor alle patienten 1, dus variabele PrimaryFirst verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ DataSet6 zonder duplicates toegevoegd aan DataSet5 middels merge file add cases omdat beide dataset info over andere patienten bevatten. Hierna bestaat DataSet5 uit MED1 en MED2.

Dataset activate DataSet5.
ADD FILES /FILE=*
  /FILE='DataSet6'.
EXECUTE.

*/CSV Bestand MED3 (=DataSet7) opgeslagen als MED3_onaangepast_15-08 en vanuit daar geopend zodat het laden minder lang duurt.  

GET
  FILE='I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS '+
    'analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor '+
    'baseline\MED3_onaangepast_15-08.sav'.
DATASET NAME DataSet7 WINDOW=FRONT.

*/ Niet essentiele variabelen verwijderd uit MED3 om het bestand te comprimeren zodat het bij de andere medicatie files kan worden toegevoegd. 

DELETE VARIABLES Extractiedatum to EndDate.
DELETE VARIABLES PRAKNR to Voorschrijfdatum.
DELETE VARIABLES Einddatum to dGPK. 
DELETE VARIABLES dSHB to dSpecialisme.

 */ Om DataSet7 te verkleinen duplicates verwijderd. Duplicates geselecteerd obv PATNR, binnen groep geselecteerd op dVoorschrijfdatum First=Primary. 

DATASET ACTIVATE DataSet7.
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) dVoorschrijfdatum(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*/ Duplicates verwijderd middels select cases, if condition is satisfied PrimaryFirst=1, delete unselected cases.

Dataset activate DataSet7. 
FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*/ DataSet6 bestaat nu enkel nog uit primary cases. PrimaryFirst is voor alle patienten 1, dus variabele PrimaryFirst verwijderd.

DELETE VARIABLES PrimaryFirst.

*/ DataSet7 zonder duplicates toegevoegd aan DataSet5 middels merge file add cases omdat beide dataset info over andere patienten bevatten. Hierna bestaat DataSet5 uit MED1, MED2 en MED3.
*/ PM to self: DataSet5 (met alle medicatie) bevat geen duplicates meer. 

Dataset activate DataSet5.
ADD FILES /FILE=*
  /FILE='DataSet7'.
EXECUTE.

*/ DataSet5 toegevoegd aan DataSet1 middels merge add variables. 

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet5.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='DataSet5'
  /BY PATNR.
EXECUTE.

*/ Om het totaal aantal medicijnen te kunnen opdelen per type, namelijk diabetes medicatie, anti-mycotica en immuunsuppresiva, de lengte van ATC aangepast. 
*/ ATC3letters: om een indeling te maken o.b.v. hoofdcategorieen medicatie (diabetes medicatie (A10), anti-mycotica (D01) en immuunsuppresiva (L01, L02, L04 H02) 
*/ ATC4letters: om bovenstaande hoofdcategorieen verder op te delen in insulinen (analogen)/non-insuline(analogen) en lokale anti-mycotica/orale anti-mycotica obv ATC4letters.
*/ Met CHAR.SUBSTR deze aanpassing maakt SPSS een variabele welke enkel de letters en getallen bevat nodig voor de indeling van de medicatie.
 
DATASET ACTIVATE DataSet1.
string ATC3letters (a7).
COMPUTE ATC3letters = CHAR.SUBSTR (dATC,1,3). 
string ATC4letters (a7).
COMPUTE ATC4letters = CHAR.SUBSTR (dATC,1,4). 

*/ Variabele aangemaakt: medicatie 6 maanden voor T0 tot T0 

* Date and Time Wizard: TijdTussenVoorschriftMedicatie_Diabetes.
DATASET ACTIVATE DataSet1.
COMPUTE  TijdTussenVoorschrift_Diabetes=RND((dVoorschrijfdatum - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenVoorschrift_Diabetes "TijdTussenVoorschriftMedicatie_Diabetes".
VARIABLE LEVEL  TijdTussenVoorschrift_Diabetes (SCALE).
FORMATS  TijdTussenVoorschrift_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenVoorschrift_Diabetes (5).
EXECUTE.

RECODE TijdTussenVoorschrift_Diabetes (-6 thru 0=1) (ELSE=0) INTO Medicatie_T0.
VARIABLE LABELS  Medicatie_T0 'Medicatie op baseline'.
EXECUTE.

*/ Variabele gemaakt voor Medicatie na baseline (T0). 

COMPUTE Medicatie_NaT0=TijdTussenVoorschrift_Diabetes  > 0.
EXECUTE.

*/ Enkel de eerste letter met de daarop volgende twee getallen nodig voor de indeling op basis van hoofdcodes. 
*/ Hoofdcategorieen verder opgedeeld in insulinen (analogen)/non-insuline(analogen) en lokale anti-mycotica/orale anti-mycotica obv ATC4letters.
*/ Alle antimycotica die niet lokaal zijn, zijn systemisch, dus ATC4letter D01A=0 = systemische antimycotica.

RECODE ATC3letters ('A10'=1) ('A10'=1) (ELSE=0) INTO Diabetesmedicatie.
RECODE ATC4letters ('A10A'=1) (ELSE=0) INTO Insulinen_plusAnalogen.

*/ Variabele gemaakt voor patiënten die anti-diabetica gebruiken op T0. 

COMPUTE Medicatie_diabetes_T0=(Diabetesmedicatie = 1) AND (Medicatie_T0=1).
EXECUTE.

*/ Variabele gemaakt voor diabetes medicatie na baseline (T0). 

COMPUTE Medicatie_diabetes_NaT0=TijdTussenVoorschrift_Diabetes  > 0.
EXECUTE.

RECODE Medicatie_diabetes_T0 Medicatie_diabetes_NaT0 (1=1) (ELSE=0).
EXECUTE.

*/ Variabele gemaakt voor patiënten die insuline (analogen) gebruiken op T0. 

COMPUTE Insulinen_analogen_T0=(Insulinen_plusAnalogen = 1) AND (Medicatie_T0=1).
EXECUTE.

*/ Variabele gemaakt voor insulinen(analogen) na baseline (T0). 

COMPUTE Insulinen_plusAnalogenNaT0=(Insulinen_plusAnalogen=1) AND (TijdTussenVoorschrift_Diabetes > 0).
EXECUTE.

*/ Immuunsuppressiva. 

DATASET ACTIVATE DataSet1.
RECODE ATC3letters ('H02'=1) ('H02'=1) ('L01'=1) ('L02'=1) ('L04'=1) (ELSE=0) INTO Immuunsuppressiva.

*/ Variabele gemaakt voor patiënten die immuunsuppressiva gebruiken op T0. 

COMPUTE Immuunsuppressiva_T0=(Immuunsuppressiva = 1) AND (Medicatie_T0=1).
EXECUTE.

*/ Variabele gemaakt voor immuunsuppressiva na baseline (T0). 

COMPUTE ImmuunsuppressivaNaT0=(Immuunsuppressiva=1) AND (TijdTussenVoorschrift_Diabetes > 0).
EXECUTE.

*/ Anti-mycotica. 

RECODE ATC4letters ('D01A'=1) ('D01B'=1) (ELSE=0) INTO Anti_mycotica.
RECODE ATC4letters ('D01A'=1) (ELSE=0) INTO Lokale_antimycotica.
RECODE ATC4letters ('D01B'=1) (ELSE=0) INTO Systemische_antimycotica. 

*/ Variabele gemaakt voor patiënten die anti-mycotica gebruiken op T0. 

COMPUTE Anti_mycotica_T0=(Anti_mycotica = 1) AND (Medicatie_T0=1).
EXECUTE.

COMPUTE Anti_mycotica_NaT0=(Anti_mycotica= 1) AND (TijdTussenVoorschrift_Diabetes > 0).
EXECUTE.

*/ Variabele gemaakt voor patiënten die lokale anti-mycotica/systemische anti-mycotica gebruiken op of na T0. 

COMPUTE Lokale_antimycotica_T0=(Lokale_antimycotica = 1) AND (Medicatie_T0=1).
EXECUTE.

COMPUTE Lokale_antimycoticaNaT0=(Lokale_antimycotica=1) AND (TijdTussenVoorschrift_Diabetes > 0).
EXECUTE.

COMPUTE Systemische_antimycotica_T0=(Systemische_antimycotica = 1) AND (Medicatie_T0=1).
EXECUTE.

COMPUTE Systemische_antimycoticaNaT0=(Systemische_antimycotica=1) AND (TijdTussenVoorschrift_Diabetes > 0).
EXECUTE.

*/ SYNTAX LAB 
* Encoding: UTF-8.

*/ CSV bestand lab, na aanpassingen, opgeslagen zodat het laden minder tijd kost. Opgeslagen als Lab_onbewerkt_05-10. Deze hieronder geopend. 
*/ Verder gegaan met tellen van Datasets. Laatste medicatie dataset was DataSet12 dus de dataset met labwaardes wordt DataSet13. 

GET
  FILE='I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS '+
    'analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor '+
    'baseline\Lab onbewerkt_05-10.sav'.
DATASET NAME DataSet13 WINDOW=FRONT.

*/ Indien variabelen dubbel aanwezig zijn in het originele bestand, dVariabele behouden. Behalve voor de variabelen Boven- en ondergrens want dBovengrens en dOndergrens bevatten geen data. 
*/ Enkel PATNR, Bepalingsdatum, dWCIANummer en Resultaat behouden om bestand te comprimeren. 
*/ dWCIANummer bevat meer dan iWCIANummer dus de eerste behouden 
*/ Bepalingdatum bevat meer dan dBepalingdatum. Omdat deze variabele essentieel is Bepalingdatum behouden. 
*/ Voor de baseline tabel is het zowel interessant of de labwaarde afwijkend is als wat het gemiddelde is van de verschillende labwaardes, dus variabelen dAfwijking en LaboratoriumUitslag behouden 

DATASET ACTIVATE DataSet13.
DELETE VARIABLES Extractiedatum to EndDate. 
DELETE VARIABLES PRAKNR to EpisodeID. 
DELETE VARIABLES dBepalingdatum to WCIANummer.
DELETE VARIABLES dWCIAOmschrijving to dResultaattype. 
DELETE VARIABLES Resultaattoevoeging to Afwijking. 
DELETE VARIABLES Bovengrens to iResultaatgeldigheid.

*/ PM analyse descriptive statistics frequencies laat zien dast 'Resultaat' ook tekstuele waardes heeft. Bijvoorbeeld: -volgt, TC over 2w etc. 

*/dAFwijking: is de laboratoriumuitslag afwijkend (true) of niet (false). WaardeAfwijkend 1= ja 0=nee. 

DATASET ACTIVATE DataSet13.
RECODE dAfwijking ('True'=1) ('False'=0) INTO WaardeAfwijkend. 

*/ PM: niet alle waardes zijn geclassificeerd als True/False, dus niet bij elke waarde staat of hij wel/niet afwijkend is. 

*/ Door de bovenstaande opdracht is dAfwijking obsoleet geworden 

DELETE VARIABLES dAfwijking. 

*/ Width van Bepalingsdatum omgezet in 10 om deze variabele vervolgens om te kunnen zetten van variable type String naar Date. 

ALTER TYPE Bepalingdatum (a10). 
ALTER TYPE Bepalingdatum (sdate10).

*/ Variabelen ter verduidelijking hernoemd of een label gegeven

RENAME VARIABLES (Resultaat=LaboratoriumUitslag). 

*/ DataSet13 bevat nog duplicates. Die, zoals hiervoorbeschreven met de andere dataset, verwijderd. 

DATASET ACTIVATE DataSet13. 
* Identify Duplicate Cases.
SORT CASES BY PATNR(A) Bepalingdatum(A).
MATCH FILES
  /FILE=*
  /BY PATNR
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

DELETE VARIABLES PrimaryFirst.

*/ DataSet13 zonder duplicates toegevoegd aan DataSet1. 

DATASET ACTIVATE DataSet1.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet13.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='DataSet13'
  /BY PATNR.
EXECUTE.

*/ WCIAnummers omgezet in bepalingen. Eerst middels analyse descriptive statistics frequencies gekeken welke dWCIANummers er zijn. 
*/ WCIAnummer 42 (=ACR 24uurs urine) bevat maar 3 waardes, dus dit WCIAnummer niet gebruikt. 

DATASET ACTIVATE DataSet1.
RECODE dWCIANummer (40=1) (ELSE=0) INTO ACR.
VARIABLE LABELS ACR 'Albumine_creatinine_ratio'.

*/ Een los bestand maken me ACR en hierin LaboratoriumUitslag de naam geven UitslagACR om duidelijk te maken dat deze bij ACR hoort. 

DATASET COPY  ACR.
DATASET ACTIVATE  ACR.
FILTER OFF.
USE ALL.
SELECT IF (ACR=1).
EXECUTE.

RENAME VARIABLES (LaboratoriumUitslag=LabUitslagACR). 

*/ Variabele gemaakt voor de tijd tussen bepaling ACR en baseline (6 maanden voor T0 tot T0). 

* Date and Time Wizard: TijdTussenACR_Diabetes.
DATASET ACTIVATE ACR.
COMPUTE  TijdTussenACR_Diabetes=RND((Bepalingdatum - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenACR_Diabetes "TijdTussenACRMedicatie_Diabetes".
VARIABLE LEVEL  TijdTussenACR_Diabetes (SCALE).
FORMATS  TijdTussenACR_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenACR_Diabetes (5).
EXECUTE.

RECODE TijdTussenACR_Diabetes (-6 thru 0=1) (ELSE=0) INTO ACR_T0.
VARIABLE LABELS  ACR_T0 'ACR op baseline'.
EXECUTE.

*/ Om de IF functie te kunnen gebruiken moeten de variabelen van hetzelfde type zijn. ACR_T0 is een numerieke variabele, dus LabUitslagACR ook omgezet in een numerieke variabele.

ALTER TYPE LabUitslagACR (f2). 

*/ Variabele LabUitslagACR_T0 aangemaakt.

dataset activate ACR. 
IF (ACR_T0=1) LabUitslagACR_T0=LabUitslagACR. 

*/ Variabele gemaakt voor ACR na T0.

dataset activate ACR.
IF (ACR_T0=0) LabUitslagACR_naT0=LabUitslagACR.

*/ Losse bestand met ACR's gemerged met DataSet1 middels merge add variables.

SORT CASES BY PATNR.
DATASET ACTIVATE ACR.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='ACR'
  /RENAME (ACR Anti_mycotica Anti_mycotica_NaT0 Anti_mycotica_T0 ATC3letters ATC4letters 
    Bepalingdatum Cellulitis Cellulitis_T0 Cellulitis_naT0 Chirurgische_ingreep_T0 Chirurgische_ingreep 
    Chirurgische_ingreep_naT0 Verrichtingcode Complicatie_anderzins_naT0 Complicatie_anderzins_T0 
    Complicatie_enige_vorm_NaT0 Complicatie_enige_vorm_T0 dAfwijking dATC Datum_Chirurgische_ingreep 
    DatumVanVerrichting_Ulcus_cruris DatumVerwijzing Diabetes_T90_ja_nee Diabetes_type_1_ja_nee 
    Diabetes_type_2_ja_nee Diabetes_alle Diabetesmedicatie dInschrijfdatum dNHGNummer dSpecialisme 
    dUitschrijfdatum dVektiscode dVoorschrijfdatum dWCIANummer Eczeem Eczeem_T0 Enkeloedeem 
    Enkeloedeem_T0 EpisodeID Erysipelas Erysipelas_T0 Erysipelas_naT0 Extractiedatum Geboortejaar 
    dGeslacht Geslacht Huidaandoening_T0 dICPC Immuunsuppressiva Immuunsuppressiva_T0 
    ImmuunsuppressivaNaT0 Infectieuze_complicatie Infectieuze_complicatie_naT0 
    Infectieuze_complicatie_T0 Insulinen_analogen_T0 Insulinen_plusAnalogen Insulinen_plusAnalogenNaT0 
    Extractie_jaar JaarUitschrijven Jaar_diagnose_diabetes_alle Leeftijd_T0 Lichen_ruber_planus_T0 
    Lichen_ruber_planus Lokale_antimycotica Lokale_antimycotica_T0 Lokale_antimycoticaNaT0 Medicatie_T0 
    Medicatie_diabetes_NaT0 Medicatie_diabetes_T0 Medicatie_NaT0 Neuropathie Neuropathie_T0 
    Omschrijving Onychomycose OnychomycoseNaT0 Onychomycose_T0 Overleden Overlijdensjaar 
    Paronychia_panaritium Paronychia_panaritium_T0 Paronychia_panaritium_naT0 
    Perifeer_arterieel_vaatlijden_T0 Perifeer_arterieel_vaatlijden Psoriasis Psoriasis_T0 
    Begindatum_Cellulitis Begindatum_Diabetes_alle Begindatum_Diabetes_type1 Begindatum_Diabetes_type2 
    Begindatum_Eczeem Begindatum_Enkeloedeem Begindatum_Erysipelas Begindatum_Lichen_ruber_planus 
    Begindatum_Neuropathie Begindatum_Onychomycose Begindatum_Paronychia_panaritium 
    Begindatum_Perifeer_arterieel_vaatlijden Begindatum_Psoriasis Begindatum_Tabaksmisbruik 
    Begindatum_Tinea_Pedis Begindatum_Ulcus Begindatum_Unguis_incarnatus 
    Begindatum_Veneuze_insufficientie BegindatumT90 Systemische_antimycotica 
    Systemische_antimycotica_T0 Systemische_antimycoticaNaT0 Tabaksmisbruik Tabaksmisbruik_T0 
    Tabaksmisbruik_NaT0 TijdTussenOnychomycose_Diabetes TijdTussenCellulitis_Diabetes 
    TijdTussenChirurgische_ingreep_Diabetes TijdTussenEczeem_Diabetes TijdTussenEnkeloedeem_Diabetes 
    TijdTussenErysipelas_Diabetes TijdTussenExtractie_Overlijden TijdTussenLichen_ruber_planus_Diabetes 
    TijdTussenNeuropathie_Diabetes TijdTussenParonychia_panaritium_Diabetes 
    TijdTussenPerifeer_arterieel_vaatlijden_Diabetes TijdTussenPsoriasis_Diabetes 
    TijdTussenTabaksmisbruik_Diabetes TijdTussenTinea_Pedis_Diabetes TijdTussenUitschrijven_Overlijden 
    TijdTussenUlcus_cruris_Diabetes TijdTussenUlcus_Diabetes TijdTussenUnguis_incarnatus_Diabetes 
    TijdTussenVeneuze_insufficientie_Diabetes TijdTussenVerwijzing_Diabetes 
    TijdTussenVoorschrift_Diabetes Tinea_PedisNaT0 Tinea_Pedis_T0 Tinea_Pedis dNHGMemo Ulcus UlcusNaT0 
    Ulcus_T0 Ulcus_cruris Ulcus_cruris_T0 Ulcus_cruris_naT0 Ulcus_Totaal_NaT0 Ulcus_Totaal_T0 
    Unguis_incarnatus_T0 Unguis_incarnatus Unguis_incarnatus_naT0 Veneuze_insufficientie 
    Veneuze_insufficientie_T0 Verwezen_tweedelijn Verwijzing_T0 Verwijzing_naT0 WaardeAfwijkend = d0 d1 
    d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 d25 d26 d27 d28 
    d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 d50 d51 d52 d53 
    d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73 d74 d75 d76 d77 d78 
    d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d100 d101 d102 
    d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 d118 d119 d120 d121 d122 
    d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 d138 d139 d140 d141 d142 
    d143 d144 d145 d146 d147 d148 d149 d150 d151 d152) 
  /BY PATNR
  /DROP= d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 
    d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 
    d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73 d74 
    d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 
    d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 d118 d119 
    d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 d138 d139 
    d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152.
EXECUTE.

*/ PM to self: binnen het bestand ACR gecheckt: heel aantal patienten hebben een 'missing' waarde voor de variabele ACR_T0.

*/ Choleserol/HDL-cholesterol ratio 

DATASET ACTIVATE DataSet1.
RECODE dWCIANummer (181=1) (ELSE=0) INTO chol_HDLc.
VARIABLE LABELS  chol_HDLc 'chol_HDc'.
EXECUTE.

*/ Los bestand gemaakt voor Choleserol/HDL-cholesterol ratio

DATASET COPY  chol_HDLc.
DATASET ACTIVATE  chol_HDLc.
FILTER OFF.
USE ALL.
SELECT IF (chol_HDLc=1).
EXECUTE.

RENAME VARIABLES (LaboratoriumUitslag=LabUitslagChol_HDLc). 

*/ Variabele gemaakt voor de tijd tussen bepaling chol_HDLc en baseline (6 maanden voor T0 tot T0). 

* Date and Time Wizard: TijdTussenchol_HDLc_Diabetes.
DATASET ACTIVATE chol_HDLc. 
COMPUTE  TijdTussenchol_HDLc_Diabetes=RND((Bepalingdatum - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenchol_HDLc_Diabetes "TijdTussenchol_HDLc_Diabetes".
VARIABLE LEVEL  TijdTussenchol_HDLc_Diabetes (SCALE).
FORMATS  TijdTussenchol_HDLc_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenchol_HDLc_Diabetes (5).
EXECUTE.

RECODE TijdTussenchol_HDLc_Diabetes (-6 thru 0=1) (ELSE=0) INTO chol_HDLc_T0.
VARIABLE LABELS  chol_HDLc_T0 'chol_HDLc op baseline'.
EXECUTE.

*/ Om de IF functie te kunnen gebruiken moeten de variabelen van hetzelfde type zijn. chol_HDLc_T0 is een numerieke variabele, dus LabUitslagChol_HDLcook omgezet in een numerieke variabele.

ALTER TYPE LabUitslagChol_HDLc (f2). 

*/ Variabele LabUitslagChol_HDLc_T0 aangemaakt.

dataset activate chol_HDLc. 
IF (chol_HDLc_T0=1) LabUitslagChol_HDLc_T0=LabUitslagChol_HDLc. 

*/ Variabele gemaakt voor chol_HDLc na T0.

dataset activate chol_HDLc.
IF (chol_HDLc_T0=0) LabUitslagChol_HDLc_naT0=LabUitslagChol_HDLc.

*/ PM to self: binnen het bestand Chol_HDLc gecheckt: heel aantal patienten hebben een 'missing' waarde voor de variabele Chol_HDLc_T0.

*/ Losse bestand met chol_HDLc gemerged met DataSet1 zodat er een variabele LabUitslagChol_HDLc wordt toegevoegd.

SORT CASES BY PATNR.
DATASET ACTIVATE chol_HDLc.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='chol_HDLc'
  /RENAME (ACR_T0 ACR Anti_mycotica Anti_mycotica_NaT0 Anti_mycotica_T0 ATC3letters ATC4letters 
    Bepalingdatum Cellulitis Cellulitis_T0 Cellulitis_naT0 Chirurgische_ingreep_T0 Chirurgische_ingreep 
    Chirurgische_ingreep_naT0 chol_HDLc Verrichtingcode Complicatie_anderzins_naT0 
    Complicatie_anderzins_T0 Complicatie_enige_vorm_NaT0 Complicatie_enige_vorm_T0 dAfwijking dATC 
    Datum_Chirurgische_ingreep DatumVanVerrichting_Ulcus_cruris DatumVerwijzing Diabetes_T90_ja_nee 
    Diabetes_type_1_ja_nee Diabetes_type_2_ja_nee Diabetes_alle Diabetesmedicatie dInschrijfdatum 
    dNHGNummer dSpecialisme dUitschrijfdatum dVektiscode dVoorschrijfdatum dWCIANummer Eczeem Eczeem_T0 
    Enkeloedeem Enkeloedeem_T0 EpisodeID Erysipelas Erysipelas_T0 Erysipelas_naT0 Extractiedatum 
    Geboortejaar dGeslacht Geslacht Huidaandoening_T0 dICPC Immuunsuppressiva Immuunsuppressiva_T0 
    ImmuunsuppressivaNaT0 Infectieuze_complicatie Infectieuze_complicatie_naT0 
    Infectieuze_complicatie_T0 Insulinen_analogen_T0 Insulinen_plusAnalogen Insulinen_plusAnalogenNaT0 
    Extractie_jaar JaarUitschrijven Jaar_diagnose_diabetes_alle LabUitslagACR LabUitslagACR_naT0 
    LabUitslagACR_T0 Leeftijd_T0 Lichen_ruber_planus_T0 Lichen_ruber_planus Lokale_antimycotica 
    Lokale_antimycotica_T0 Lokale_antimycoticaNaT0 Medicatie_T0 Medicatie_diabetes_NaT0 
    Medicatie_diabetes_T0 Medicatie_NaT0 Neuropathie Neuropathie_T0 Omschrijving Onychomycose 
    OnychomycoseNaT0 Onychomycose_T0 Overleden Overlijdensjaar Paronychia_panaritium 
    Paronychia_panaritium_T0 Paronychia_panaritium_naT0 Perifeer_arterieel_vaatlijden_T0 
    Perifeer_arterieel_vaatlijden Psoriasis Psoriasis_T0 Begindatum_Cellulitis Begindatum_Diabetes_alle 
    Begindatum_Diabetes_type1 Begindatum_Diabetes_type2 Begindatum_Eczeem Begindatum_Enkeloedeem 
    Begindatum_Erysipelas Begindatum_Lichen_ruber_planus Begindatum_Neuropathie Begindatum_Onychomycose 
    Begindatum_Paronychia_panaritium Begindatum_Perifeer_arterieel_vaatlijden Begindatum_Psoriasis 
    Begindatum_Tabaksmisbruik Begindatum_Tinea_Pedis Begindatum_Ulcus Begindatum_Unguis_incarnatus 
    Begindatum_Veneuze_insufficientie BegindatumT90 Systemische_antimycotica 
    Systemische_antimycotica_T0 Systemische_antimycoticaNaT0 Tabaksmisbruik Tabaksmisbruik_T0 
    Tabaksmisbruik_NaT0 TijdTussenOnychomycose_Diabetes TijdTussenACR_Diabetes 
    TijdTussenCellulitis_Diabetes TijdTussenChirurgische_ingreep_Diabetes TijdTussenEczeem_Diabetes 
    TijdTussenEnkeloedeem_Diabetes TijdTussenErysipelas_Diabetes TijdTussenExtractie_Overlijden 
    TijdTussenLichen_ruber_planus_Diabetes TijdTussenNeuropathie_Diabetes 
    TijdTussenParonychia_panaritium_Diabetes TijdTussenPerifeer_arterieel_vaatlijden_Diabetes 
    TijdTussenPsoriasis_Diabetes TijdTussenTabaksmisbruik_Diabetes TijdTussenTinea_Pedis_Diabetes 
    TijdTussenUitschrijven_Overlijden TijdTussenUlcus_cruris_Diabetes TijdTussenUlcus_Diabetes 
    TijdTussenUnguis_incarnatus_Diabetes TijdTussenVeneuze_insufficientie_Diabetes 
    TijdTussenVerwijzing_Diabetes TijdTussenVoorschrift_Diabetes Tinea_PedisNaT0 Tinea_Pedis_T0 
    Tinea_Pedis dNHGMemo Ulcus UlcusNaT0 Ulcus_T0 Ulcus_cruris Ulcus_cruris_T0 Ulcus_cruris_naT0 
    Ulcus_Totaal_NaT0 Ulcus_Totaal_T0 Unguis_incarnatus_T0 Unguis_incarnatus Unguis_incarnatus_naT0 
    Veneuze_insufficientie Veneuze_insufficientie_T0 Verwezen_tweedelijn Verwijzing_T0 Verwijzing_naT0 
    WaardeAfwijkend = d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 
    d23 d24 d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 
    d48 d49 d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 
    d73 d74 d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 
    d98 d99 d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 
    d118 d119 d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 
    d138 d139 d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 
    d158) 
  /BY PATNR
  /DROP= d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 
    d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 
    d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73 d74 
    d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 
    d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 d118 d119 
    d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 d138 d139 
    d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 d158.
EXECUTE.

*/ Sommige WCIA nummers staan niet in de bepalingen viewer: 41, 368, 415, 1713, 2005, 2020

*/ 372= glucose nuchter, veneus 
*/ 3208= glucose nuchter, art/cap (bevat 5 waardes). Omdat deze diagnostische bepaling zo weinig waardes bevat, samengevoegd met Nuchter_glucose_veneus. 

DATASET ACTIVATE DataSet1.
RECODE dWCIANummer (372=1) (3208=1) (ELSE=0) INTO Glucose_nuchter.
VARIABLE LABELS  Glucose_nuchter 'Glucose_nuchter'.
EXECUTE.

*/ Los bestand gemaakt voor Glucose_nuchter

DATASET COPY  Glucose_nuchter.
DATASET ACTIVATE  Glucose_nuchter.
FILTER OFF.
USE ALL.
SELECT IF (Glucose_nuchter=1).
EXECUTE.

RENAME VARIABLES (LaboratoriumUitslag=LabUitslagGlucose_nuchter). 

*/ Variabele gemaakt voor de tijd tussen bepaling Glucose_nuchteren baseline (6 maanden voor T0 tot T0). 

* Date and Time Wizard: TijdTussenGlucose_nuchter_Diabetes.
DATASET ACTIVATE Glucose_nuchter. 
COMPUTE  TijdTussenGlucose_nuchter_Diabetes=RND((Bepalingdatum - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenGlucose_nuchter_Diabetes "TijdTussenGlucose_nuchter_Diabetes".
VARIABLE LEVEL  TijdTussenGlucose_nuchter_Diabetes (SCALE).
FORMATS  TijdTussenGlucose_nuchter_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenGlucose_nuchter_Diabetes (5).
EXECUTE.

RECODE TijdTussenGlucose_nuchter_Diabetes (-6 thru 0=1) (ELSE=0) INTO Glucose_nuchter_T0.
VARIABLE LABELS Glucose_nuchter_T0 'Glucose_nuchter op baseline'.
EXECUTE.

*/ Om de IF functie te kunnen gebruiken moeten de variabelen van hetzelfde type zijn. Glucose_nuchter_T0 is een numerieke variabele, dus LabUitslagGlucose_nuchter ook omgezet in een numerieke variabele.

ALTER TYPE LabUitslagGlucose_nuchter (f2). 

*/ Variabele LabUitslagGlucose_nuchter_T0 aangemaakt.

dataset activate Glucose_nuchter. 
IF (Glucose_nuchter_T0=1) LabUitslagGlucose_nuchter_T0=LabUitslagGlucose_nuchter. 

*/ Variabele gemaakt voor chol_HDLc na T0.

dataset activate Glucose_nuchter.
IF (chol_HDLc_T0=0) LabUitslagGlucose_nuchter_naT0=LabUitslagGlucose_nuchter.

*/ PM to self: LabUitslagGlucose_nuchter_naT0 bevat geen waardes. 

*/ Losse bestand voor Glucose_nuchter toegevoegd aan DataSet1.

SORT CASES BY PATNR.
DATASET ACTIVATE Glucose_nuchter.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='Glucose_nuchter'
  /RENAME (ACR_T0 ACR Anti_mycotica Anti_mycotica_NaT0 Anti_mycotica_T0 ATC3letters ATC4letters 
    Bepalingdatum Cellulitis Cellulitis_T0 Cellulitis_naT0 Chirurgische_ingreep_T0 Chirurgische_ingreep 
    Chirurgische_ingreep_naT0 chol_HDLc chol_HDLc_T0 Verrichtingcode Complicatie_anderzins_naT0 
    Complicatie_anderzins_T0 Complicatie_enige_vorm_NaT0 Complicatie_enige_vorm_T0 dAfwijking dATC 
    Datum_Chirurgische_ingreep DatumVanVerrichting_Ulcus_cruris DatumVerwijzing Diabetes_T90_ja_nee 
    Diabetes_type_1_ja_nee Diabetes_type_2_ja_nee Diabetes_alle Diabetesmedicatie dInschrijfdatum 
    dNHGNummer dSpecialisme dUitschrijfdatum dVektiscode dVoorschrijfdatum dWCIANummer Eczeem Eczeem_T0 
    Enkeloedeem Enkeloedeem_T0 EpisodeID Erysipelas Erysipelas_T0 Erysipelas_naT0 Extractiedatum 
    Geboortejaar dGeslacht Geslacht Glucose_nuchter Huidaandoening_T0 dICPC Immuunsuppressiva 
    Immuunsuppressiva_T0 ImmuunsuppressivaNaT0 Infectieuze_complicatie Infectieuze_complicatie_naT0 
    Infectieuze_complicatie_T0 Insulinen_analogen_T0 Insulinen_plusAnalogen Insulinen_plusAnalogenNaT0 
    Extractie_jaar JaarUitschrijven Jaar_diagnose_diabetes_alle LabUitslagACR LabUitslagACR_naT0 
    LabUitslagACR_T0 LabUitslagChol_HDLc LabUitslagChol_HDLc_naT0 LabUitslagChol_HDLc_T0 Leeftijd_T0 
    Lichen_ruber_planus_T0 Lichen_ruber_planus Lokale_antimycotica Lokale_antimycotica_T0 
    Lokale_antimycoticaNaT0 Medicatie_T0 Medicatie_diabetes_NaT0 Medicatie_diabetes_T0 Medicatie_NaT0 
    Neuropathie Neuropathie_T0 Omschrijving Onychomycose OnychomycoseNaT0 Onychomycose_T0 Overleden 
    Overlijdensjaar Paronychia_panaritium Paronychia_panaritium_T0 Paronychia_panaritium_naT0 
    Perifeer_arterieel_vaatlijden_T0 Perifeer_arterieel_vaatlijden Psoriasis Psoriasis_T0 
    Begindatum_Cellulitis Begindatum_Diabetes_alle Begindatum_Diabetes_type1 Begindatum_Diabetes_type2 
    Begindatum_Eczeem Begindatum_Enkeloedeem Begindatum_Erysipelas Begindatum_Lichen_ruber_planus 
    Begindatum_Neuropathie Begindatum_Onychomycose Begindatum_Paronychia_panaritium 
    Begindatum_Perifeer_arterieel_vaatlijden Begindatum_Psoriasis Begindatum_Tabaksmisbruik 
    Begindatum_Tinea_Pedis Begindatum_Ulcus Begindatum_Unguis_incarnatus 
    Begindatum_Veneuze_insufficientie BegindatumT90 Systemische_antimycotica 
    Systemische_antimycotica_T0 Systemische_antimycoticaNaT0 Tabaksmisbruik Tabaksmisbruik_T0 
    Tabaksmisbruik_NaT0 TijdTussenOnychomycose_Diabetes TijdTussenACR_Diabetes 
    TijdTussenCellulitis_Diabetes TijdTussenChirurgische_ingreep_Diabetes TijdTussenchol_HDLc_Diabetes 
    TijdTussenEczeem_Diabetes TijdTussenEnkeloedeem_Diabetes TijdTussenErysipelas_Diabetes 
    TijdTussenExtractie_Overlijden TijdTussenLichen_ruber_planus_Diabetes 
    TijdTussenNeuropathie_Diabetes TijdTussenParonychia_panaritium_Diabetes 
    TijdTussenPerifeer_arterieel_vaatlijden_Diabetes TijdTussenPsoriasis_Diabetes 
    TijdTussenTabaksmisbruik_Diabetes TijdTussenTinea_Pedis_Diabetes TijdTussenUitschrijven_Overlijden 
    TijdTussenUlcus_cruris_Diabetes TijdTussenUlcus_Diabetes TijdTussenUnguis_incarnatus_Diabetes 
    TijdTussenVeneuze_insufficientie_Diabetes TijdTussenVerwijzing_Diabetes 
    TijdTussenVoorschrift_Diabetes Tinea_PedisNaT0 Tinea_Pedis_T0 Tinea_Pedis dNHGMemo Ulcus UlcusNaT0 
    Ulcus_T0 Ulcus_cruris Ulcus_cruris_T0 Ulcus_cruris_naT0 Ulcus_Totaal_NaT0 Ulcus_Totaal_T0 
    Unguis_incarnatus_T0 Unguis_incarnatus Unguis_incarnatus_naT0 Veneuze_insufficientie 
    Veneuze_insufficientie_T0 Verwezen_tweedelijn Verwijzing_T0 Verwijzing_naT0 WaardeAfwijkend = d0 d1 
    d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 d25 d26 d27 d28 
    d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 d50 d51 d52 d53 
    d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73 d74 d75 d76 d77 d78 
    d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 d100 d101 d102 
    d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 d118 d119 d120 d121 d122 
    d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 d138 d139 d140 d141 d142 
    d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 d158 d159 d160 d161 d162 
    d163 d164) 
  /BY PATNR
  /DROP= d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 
    d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 
    d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73 d74 
    d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 
    d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 d118 d119 
    d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 d138 d139 
    d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 d158 d159 
    d160 d161 d162 d163 d164.
EXECUTE.

*/ Body mass index (BMI) 

DATASET ACTIVATE DataSet1.
RECODE dWCIANummer (1272=1) (ELSE=0) INTO BMI.
VARIABLE LABELS  BMI 'Body Mass Index'.
EXECUTE.

*/ Los bestand voor BMI.

DATASET COPY  BMI.
DATASET ACTIVATE  BMI.
FILTER OFF.
USE ALL.
SELECT IF (BMI=1).
EXECUTE.

RENAME VARIABLES (LaboratoriumUitslag=LabUitslagBMI). 

*/ Variabele gemaakt voor de tijd tussen bepaling BMI en baseline (6 maanden voor T0 tot T0). 

* Date and Time Wizard: TijdTussenBMI_Diabetes.
DATASET ACTIVATE BMI. 
COMPUTE  TijdTussenBMI_Diabetes=RND((Bepalingdatum - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTussenchol_BMI_Diabetes "TijdTussenchol_HDLc_Diabetes".
VARIABLE LEVEL  TijdTussenchol_BMI_Diabetes (SCALE).
FORMATS  TijdTussenchol_BMI_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenBMI_Diabetes (5).
EXECUTE.

RECODE TijdTussenBMI_Diabetes (-6 thru 0=1) (ELSE=0) INTO BMI_T0.
VARIABLE LABELS  BMI_T0 'BMI op baseline'.
EXECUTE.

*/ Om de IF functie te kunnen gebruiken moeten de variabelen van hetzelfde type zijn. Glucose_nuchter_T0 is een numerieke variabele, dus LabUitslagGlucose_nuchter ook omgezet in een numerieke variabele.

ALTER TYPE LabUitslagBMI (f2). 

*/ Variabele LabUitslagBMI_T0 aangemaakt.

dataset activate BMI. 
IF (BMI_T0=1) LabUitslagBMI_T0=LabUitslagBMI. 

*/ Variabele gemaakt voor BMI na T0.

dataset activate BMI.
IF (BMI_T0=0) LabUitslagBMI_naT0=LabUitslagBMI.

*/ Los bestand met BMI toegevoegd aan DataSet1. 

SORT CASES BY PATNR.
DATASET ACTIVATE BMI.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='BMI'
  /RENAME (ACR_T0 ACR Anti_mycotica Anti_mycotica_NaT0 Anti_mycotica_T0 ATC3letters ATC4letters 
    Bepalingdatum BMI Cellulitis Cellulitis_T0 Cellulitis_naT0 Chirurgische_ingreep_T0 
    Chirurgische_ingreep Chirurgische_ingreep_naT0 chol_HDLc chol_HDLc_T0 Verrichtingcode 
    Complicatie_anderzins_naT0 Complicatie_anderzins_T0 Complicatie_enige_vorm_NaT0 
    Complicatie_enige_vorm_T0 dAfwijking dATC Datum_Chirurgische_ingreep 
    DatumVanVerrichting_Ulcus_cruris DatumVerwijzing Diabetes_T90_ja_nee Diabetes_type_1_ja_nee 
    Diabetes_type_2_ja_nee Diabetes_alle Diabetesmedicatie dInschrijfdatum dNHGNummer dSpecialisme 
    dUitschrijfdatum dVektiscode dVoorschrijfdatum dWCIANummer Eczeem Eczeem_T0 Enkeloedeem 
    Enkeloedeem_T0 EpisodeID Erysipelas Erysipelas_T0 Erysipelas_naT0 Extractiedatum Geboortejaar 
    dGeslacht Geslacht Glucose_nuchter Glucose_nuchter_T0 Huidaandoening_T0 dICPC Immuunsuppressiva 
    Immuunsuppressiva_T0 ImmuunsuppressivaNaT0 Infectieuze_complicatie Infectieuze_complicatie_naT0 
    Infectieuze_complicatie_T0 Insulinen_analogen_T0 Insulinen_plusAnalogen Insulinen_plusAnalogenNaT0 
    Extractie_jaar JaarUitschrijven Jaar_diagnose_diabetes_alle LabUitslagACR LabUitslagACR_naT0 
    LabUitslagACR_T0 LabUitslagChol_HDLc LabUitslagChol_HDLc_naT0 LabUitslagChol_HDLc_T0 
    LabUitslagGlucose_nuchter LabUitslagGlucose_nuchter_naT0 LabUitslagGlucose_nuchter_T0 Leeftijd_T0 
    Lichen_ruber_planus_T0 Lichen_ruber_planus Lokale_antimycotica Lokale_antimycotica_T0 
    Lokale_antimycoticaNaT0 Medicatie_T0 Medicatie_diabetes_NaT0 Medicatie_diabetes_T0 Medicatie_NaT0 
    Neuropathie Neuropathie_T0 Omschrijving Onychomycose OnychomycoseNaT0 Onychomycose_T0 Overleden 
    Overlijdensjaar Paronychia_panaritium Paronychia_panaritium_T0 Paronychia_panaritium_naT0 
    Perifeer_arterieel_vaatlijden_T0 Perifeer_arterieel_vaatlijden Psoriasis Psoriasis_T0 
    Begindatum_Cellulitis Begindatum_Diabetes_alle Begindatum_Diabetes_type1 Begindatum_Diabetes_type2 
    Begindatum_Eczeem Begindatum_Enkeloedeem Begindatum_Erysipelas Begindatum_Lichen_ruber_planus 
    Begindatum_Neuropathie Begindatum_Onychomycose Begindatum_Paronychia_panaritium 
    Begindatum_Perifeer_arterieel_vaatlijden Begindatum_Psoriasis Begindatum_Tabaksmisbruik 
    Begindatum_Tinea_Pedis Begindatum_Ulcus Begindatum_Unguis_incarnatus 
    Begindatum_Veneuze_insufficientie BegindatumT90 Systemische_antimycotica 
    Systemische_antimycotica_T0 Systemische_antimycoticaNaT0 Tabaksmisbruik Tabaksmisbruik_T0 
    Tabaksmisbruik_NaT0 TijdTussenOnychomycose_Diabetes TijdTussenACR_Diabetes 
    TijdTussenCellulitis_Diabetes TijdTussenChirurgische_ingreep_Diabetes TijdTussenchol_HDLc_Diabetes 
    TijdTussenEczeem_Diabetes TijdTussenEnkeloedeem_Diabetes TijdTussenErysipelas_Diabetes 
    TijdTussenExtractie_Overlijden TijdTussenGlucose_nuchter_Diabetes 
    TijdTussenLichen_ruber_planus_Diabetes TijdTussenNeuropathie_Diabetes 
    TijdTussenParonychia_panaritium_Diabetes TijdTussenPerifeer_arterieel_vaatlijden_Diabetes 
    TijdTussenPsoriasis_Diabetes TijdTussenTabaksmisbruik_Diabetes TijdTussenTinea_Pedis_Diabetes 
    TijdTussenUitschrijven_Overlijden TijdTussenUlcus_cruris_Diabetes TijdTussenUlcus_Diabetes 
    TijdTussenUnguis_incarnatus_Diabetes TijdTussenVeneuze_insufficientie_Diabetes 
    TijdTussenVerwijzing_Diabetes TijdTussenVoorschrift_Diabetes Tinea_PedisNaT0 Tinea_Pedis_T0 
    Tinea_Pedis dNHGMemo Ulcus UlcusNaT0 Ulcus_T0 Ulcus_cruris Ulcus_cruris_T0 Ulcus_cruris_naT0 
    Ulcus_Totaal_NaT0 Ulcus_Totaal_T0 Unguis_incarnatus_T0 Unguis_incarnatus Unguis_incarnatus_naT0 
    Veneuze_insufficientie Veneuze_insufficientie_T0 Verwezen_tweedelijn Verwijzing_T0 Verwijzing_naT0 
    WaardeAfwijkend = d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 
    d23 d24 d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 
    d48 d49 d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 
    d73 d74 d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 
    d98 d99 d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 
    d118 d119 d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 
    d138 d139 d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 
    d158 d159 d160 d161 d162 d163 d164 d165 d166 d167 d168 d169 d170) 
  /BY PATNR
  /DROP= d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 
    d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 
    d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73 d74 
    d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 
    d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 d118 d119 
    d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 d138 d139 
    d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 d158 d159 
    d160 d161 d162 d163 d164 d165 d166 d167 d168 d169 d170.
EXECUTE.

*/ Veel verschillende diagnostische bepalingen met informatie over roken. Volgende zijn niet essentieel voor de baselinetabel (met patiëntkarakteristieken): 
*/ 1814= advies stoppen met roken gegeven; 1996= wil op korte termijn stoppen met roken; 1997=aantal stoppogingen (roken); 2001=stopafspraak gemaakt (roken); 2002=afgesproken stopdatum; 2009=redenen patient gestopt met roken
2010=andere barrieres om te stoppen met roken; 2011=barrieres om te stoppen met roken; 2013=andere redenen om te stoppen met roken; 2015=bijwerkingen medicatie (stoppen met roken); 2017=vorm van behandeling roken
2019=termijn vervolg consult (roken); 2027=vervolgconsult over roken; 2033=overige afspraken stoppen met roken; 2039=afspraak follow-up (roken); 2405 motivatie stoppen met roken; 2998 belangrijkste reden stoppen met roken;
2999 voordelen stoppen, nadelen roken besproken
*/ Aangezien al het bovenstaande enkel bij rokende patiënten wordt geregistreerd, deze diagnostische codes samengevoegd tot een nieuwe variabele. Namelijk diagnostische_registraties_roken. 
*/ 1992= aantal (shag)sigaretten/dag, 1993= aantal sigaretten/dag en 2003= gestopt met roken ook meegenomen in de variabele diagnostische_registraties_roken. 

DATASET ACTIVATE DataSet1.
RECODE dWCIANummer (1739=1) (1814=1) (1992=1) (1993=1) (1996=1) (1997=1) (2011=1) (2002=1) (2009=1) (2010=1) (2013=1)
(2015=1) (2017=1) (2019=1) (2027=1) (2033=1) (2039=1) (2405=1) (2998=1) (2999=1) (ELSE=0) INTO Diagnostische_registraties_roken.
VARIABLE LABELS  Diagnostische_registraties_roken 'Diagnostische_registraties_roken'.
EXECUTE.

*/ De variabele 'afwijkend' is niet van waarde voor diagnostische registraties roken. 
*/ Tevens alleen gebruik gemaakt van roken ja/nee. Niet opgedeeld in op T0 en na T0 aangezien er vaak onduidelijkheid/onzekerheid is over stoppen/gestopt zijn. 

*/ Reeds aangemaakte variabelen Tabaksmisbruik en Diagnostische_registraties_roken gecombineerd tot een variabele: Roken 

DATASET ACTIVATE DataSet1.
COMPUTE Roken=(Diagnostische_registraties_roken = 1) OR (Tabaksmisbruik = 1).

*/ Niet mogelijk om te bepalen of roken reeds op baseline stond geregistreerd. Roken bestaat namelijk uit multiple dWCIANummers waaraan bij elke patient een andere begindatum is gekoppeld. 

*/ Duur roken niet te bepalen want datum van start roken wordt niet accuraat genoteerd.  

*/ 1919= eGFR volgen MDRD formule. 
*/ 3583 eGFR volgens CKD-EPI formule 
*/ 3741= eGFR volgens CDK-EPI POC-test 
*/ Om van zoveel mogelijk patienten informatie over de eGFR te hebben, CKD-EPI, MDRD en POC samengevoegd.
*/ 1920= glomerulaire filtratie ratio (GFR). Niet essentieel voor de baselinetabel.

DATASET ACTIVATE DataSet1. 
RECODE dWCIANummer (3583=1) (1919=1) (3741=1) (ELSE=0) INTO eGFR.
VARIABLE LABELS  eGFR 'estimated Glomerular Filtration Rate'.
EXECUTE.

*/ Los bestand voor eGFR.

DATASET COPY  eGFR.
DATASET ACTIVATE  eGFR.
FILTER OFF.
USE ALL.
SELECT IF (eGFR=1).
EXECUTE.

RENAME VARIABLES (LaboratoriumUitslag=LabUitslageGFR). 

*/ Variabele gemaakt voor de tijd tussen bepaling eGFR en baseline (6 maanden voor T0 tot T0). 

* Date and Time Wizard: TijdTussen eGFR_Diabetes.
DATASET ACTIVATE eGFR. 
COMPUTE  TijdTusseneGFR_Diabetes=RND((Bepalingdatum - Begindatum_Diabetes_alle) / (30.4375 * time.days(1))).
VARIABLE LABELS  TijdTusseneGFR_Diabetes "TijdTusseneGFR_Diabetes".
VARIABLE LEVEL  TijdTusseneGFR_Diabetes (SCALE).
FORMATS  TijdTusseneGFR_Diabetes (F5.0).
VARIABLE WIDTH  TijdTusseneGFR_Diabetes (5).
EXECUTE.

RECODE TijdTusseneGFR_Diabetes (-6 thru 0=1) (ELSE=0) INTO eGFR_T0.
VARIABLE LABELS  eGFR_T0 'eGFR op baseline'.
EXECUTE.

*/ Om de IF functie te kunnen gebruiken moeten de variabelen van hetzelfde type zijn. Glucose_nuchter_T0 is een numerieke variabele, dus LabUitslagGlucose_nuchter ook omgezet in een numerieke variabele.

ALTER TYPE LabUitslageGFR (f2). 

*/ Variabele LabUitslageGFR_T0 aangemaakt.

dataset activate eGFR. 
IF (eGFR_T0=1) LabUitslageGFR_T0=LabUitslageGFR. 

*/ Variabele gemaakt voor eGFR na T0.

dataset activate eGFR.
IF (eGFR_T0=0) LabUitslageGFR_naT0=LabUitslageGFR.

*/ Los bestand met eGFR toegevoegd aan DataSet1. 

SORT CASES BY PATNR.
DATASET ACTIVATE eGFR.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='eGFR'
  /RENAME (ACR_T0 ACR Anti_mycotica Anti_mycotica_NaT0 Anti_mycotica_T0 ATC3letters ATC4letters 
    Bepalingdatum BMI_T0 BMI Cellulitis Cellulitis_T0 Cellulitis_naT0 Chirurgische_ingreep_T0 
    Chirurgische_ingreep Chirurgische_ingreep_naT0 chol_HDLc chol_HDLc_T0 Verrichtingcode 
    Complicatie_anderzins_naT0 Complicatie_anderzins_T0 Complicatie_enige_vorm_NaT0 
    Complicatie_enige_vorm_T0 dAfwijking dATC Datum_Chirurgische_ingreep 
    DatumVanVerrichting_Ulcus_cruris DatumVerwijzing Diabetes_T90_ja_nee Diabetes_type_1_ja_nee 
    Diabetes_type_2_ja_nee Diabetes_alle Diabetesmedicatie Diagnostische_registraties_roken 
    dInschrijfdatum dNHGNummer dSpecialisme dUitschrijfdatum dVektiscode dVoorschrijfdatum dWCIANummer 
    Eczeem Eczeem_T0 Enkeloedeem Enkeloedeem_T0 EpisodeID Erysipelas Erysipelas_T0 Erysipelas_naT0 eGFR 
    Extractiedatum Geboortejaar dGeslacht Geslacht Glucose_nuchter Glucose_nuchter_T0 Huidaandoening_T0 
    dICPC Immuunsuppressiva Immuunsuppressiva_T0 ImmuunsuppressivaNaT0 Infectieuze_complicatie 
    Infectieuze_complicatie_naT0 Infectieuze_complicatie_T0 Insulinen_analogen_T0 
    Insulinen_plusAnalogen Insulinen_plusAnalogenNaT0 Extractie_jaar JaarUitschrijven 
    Jaar_diagnose_diabetes_alle LabUitslagACR LabUitslagACR_naT0 LabUitslagACR_T0 LabUitslagBMI 
    LabUitslagBMI_naT0 LabUitslagBMI_T0 LabUitslagChol_HDLc LabUitslagChol_HDLc_naT0 
    LabUitslagChol_HDLc_T0 LabUitslagGlucose_nuchter LabUitslagGlucose_nuchter_naT0 
    LabUitslagGlucose_nuchter_T0 Leeftijd_T0 Lichen_ruber_planus_T0 Lichen_ruber_planus 
    Lokale_antimycotica Lokale_antimycotica_T0 Lokale_antimycoticaNaT0 Medicatie_T0 
    Medicatie_diabetes_NaT0 Medicatie_diabetes_T0 Medicatie_NaT0 Neuropathie Neuropathie_T0 
    Omschrijving Onychomycose OnychomycoseNaT0 Onychomycose_T0 Overleden Overlijdensjaar 
    Paronychia_panaritium Paronychia_panaritium_T0 Paronychia_panaritium_naT0 
    Perifeer_arterieel_vaatlijden_T0 Perifeer_arterieel_vaatlijden Psoriasis Psoriasis_T0 Roken 
    Begindatum_Cellulitis Begindatum_Diabetes_alle Begindatum_Diabetes_type1 Begindatum_Diabetes_type2 
    Begindatum_Eczeem Begindatum_Enkeloedeem Begindatum_Erysipelas Begindatum_Lichen_ruber_planus 
    Begindatum_Neuropathie Begindatum_Onychomycose Begindatum_Paronychia_panaritium 
    Begindatum_Perifeer_arterieel_vaatlijden Begindatum_Psoriasis Begindatum_Tabaksmisbruik 
    Begindatum_Tinea_Pedis Begindatum_Ulcus Begindatum_Unguis_incarnatus 
    Begindatum_Veneuze_insufficientie BegindatumT90 Systemische_antimycotica 
    Systemische_antimycotica_T0 Systemische_antimycoticaNaT0 Tabaksmisbruik Tabaksmisbruik_T0 
    Tabaksmisbruik_NaT0 TijdTussenOnychomycose_Diabetes TijdTussenACR_Diabetes TijdTussenBMI_Diabetes 
    TijdTussenCellulitis_Diabetes TijdTussenChirurgische_ingreep_Diabetes TijdTussenchol_HDLc_Diabetes 
    TijdTussenEczeem_Diabetes TijdTussenEnkeloedeem_Diabetes TijdTussenErysipelas_Diabetes 
    TijdTussenExtractie_Overlijden TijdTussenGlucose_nuchter_Diabetes 
    TijdTussenLichen_ruber_planus_Diabetes TijdTussenNeuropathie_Diabetes 
    TijdTussenParonychia_panaritium_Diabetes TijdTussenPerifeer_arterieel_vaatlijden_Diabetes 
    TijdTussenPsoriasis_Diabetes TijdTussenTabaksmisbruik_Diabetes TijdTussenTinea_Pedis_Diabetes 
    TijdTussenUitschrijven_Overlijden TijdTussenUlcus_cruris_Diabetes TijdTussenUlcus_Diabetes 
    TijdTussenUnguis_incarnatus_Diabetes TijdTussenVeneuze_insufficientie_Diabetes 
    TijdTussenVerwijzing_Diabetes TijdTussenVoorschrift_Diabetes Tinea_PedisNaT0 Tinea_Pedis_T0 
    Tinea_Pedis dNHGMemo Ulcus UlcusNaT0 Ulcus_T0 Ulcus_cruris Ulcus_cruris_T0 Ulcus_cruris_naT0 
    Ulcus_Totaal_NaT0 Ulcus_Totaal_T0 Unguis_incarnatus_T0 Unguis_incarnatus Unguis_incarnatus_naT0 
    Veneuze_insufficientie Veneuze_insufficientie_T0 Verwezen_tweedelijn Verwijzing_T0 Verwijzing_naT0 
    WaardeAfwijkend = d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 
    d23 d24 d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 
    d48 d49 d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 
    d73 d74 d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 
    d98 d99 d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 
    d118 d119 d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 
    d138 d139 d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 
    d158 d159 d160 d161 d162 d163 d164 d165 d166 d167 d168 d169 d170 d171 d172 d173 d174 d175 d176 d177 
    d178) 
  /BY PATNR
  /DROP= d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 
    d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 
    d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73 d74 
    d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 
    d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 d118 d119 
    d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 d138 d139 
    d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 d158 d159 
    d160 d161 d162 d163 d164 d165 d166 d167 d168 d169 d170 d171 d172 d173 d174 d175 d176 d177 d178.
EXECUTE.

*/ 2645 glycohemoglobine (HbA1c) confirmatietest; 2816= HbA1c_FCC; 3754= HbA1c POC-test samengevoegd tot een variabele: HbA1c.
*/ Voor HbA1c een range van 1 jaar voor T0 tot T0 genomen. Vanuit DataSet13 waarin niet reeds geselecteerd is op diagnostische bepaling rondom diagnose DM. 

DATASET ACTIVATE DataSet1.
RECODE dWCIANummer (2816=1) (3754=1) (2645=1) (ELSE=0) INTO HbA1c.
VARIABLE LABELS  HbA1c 'HbA1c'.
EXECUTE.

*/ Los bestand voor HbA1c.

DATASET COPY  HbA1c.
DATASET ACTIVATE  HbA1c.
FILTER OFF.
USE ALL.
SELECT IF (HbA1c=1).
EXECUTE.

RENAME VARIABLES (LaboratoriumUitslag=LabUitslagHbA1c). 

*/ Variabele aangemaakt voor HbA1c 1jaar voor T0 tot T0: 
*/ (Datum bepaling HbA1c - datum registratie diagnose DM) in jaren. Round to integer.

DATASET ACTIVATE HbA1c. 
* Date and Time Wizard: TijdTussenHbA1c_Diabetes.
COMPUTE  TijdTussenHbA1c_Diabetes=RND((Bepalingdatum - Begindatum_Diabetes_alle) / (365.25 * time.days(1))).
VARIABLE LABELS  TijdTussenHbA1c_Diabetes "TijdTussenHbA1c_Diabetes".
VARIABLE LEVEL  TijdTussenHbA1c_Diabetes (SCALE).
FORMATS  TijdTussenHbA1c_Diabetes (F5.0).
VARIABLE WIDTH  TijdTussenHbA1c_Diabetes(5).
EXECUTE.

DATASET ACTIVATE HbA1c.
RECODE TijdTussenHbA1c_Diabetes (-1 thru 0=1) (ELSE=0) INTO HbA1c_T0.
VARIABLE LABELS  HbA1c_T0 'HbA1c_T0'.
EXECUTE.

*/ Om de IF functie te kunnen gebruiken moeten de variabelen van hetzelfde type zijn.  HbA1c_T0 is een numerieke variabele, dus LabUitslag HbA1c ook omgezet in een numerieke variabele.

ALTER TYPE LabUitslagHbA1c (f2). 

*/ Variabele LabUitslagHbA1c_T0 aangemaakt.

dataset activate  HbA1c. 
IF (HbA1c_T0=1) LabUitslagHbA1c_T0=LabUitslagHbA1c. 

*/ Variabele gemaakt voor HbA1c na T0.

dataset activate HbA1c.
IF (HbA1c_T0=0) LabUitslagHbA1c_naT0=LabUitslagHbA1c.

*/ Dataset HbA1c toegevoegd aan dataset1.

SORT CASES BY PATNR.
DATASET ACTIVATE HbA1c.
SORT CASES BY PATNR.
DATASET ACTIVATE DataSet1.
MATCH FILES /FILE=*
  /FILE='HbA1c'
  /RENAME (ACR_T0 ACR Anti_mycotica Anti_mycotica_NaT0 Anti_mycotica_T0 ATC3letters ATC4letters 
    Bepalingdatum BMI_T0 BMI Cellulitis Cellulitis_T0 Cellulitis_naT0 Chirurgische_ingreep_T0 
    Chirurgische_ingreep Chirurgische_ingreep_naT0 chol_HDLc chol_HDLc_T0 Verrichtingcode 
    Complicatie_anderzins_naT0 Complicatie_anderzins_T0 Complicatie_enige_vorm_NaT0 
    Complicatie_enige_vorm_T0 dAfwijking dATC Datum_Chirurgische_ingreep 
    DatumVanVerrichting_Ulcus_cruris DatumVerwijzing Diabetes_T90_ja_nee Diabetes_type_1_ja_nee 
    Diabetes_type_2_ja_nee Diabetes_alle Diabetesmedicatie Diagnostische_registraties_roken 
    dInschrijfdatum dNHGNummer dSpecialisme dUitschrijfdatum dVektiscode dVoorschrijfdatum dWCIANummer 
    Eczeem Eczeem_T0 eGFR_T0 Enkeloedeem Enkeloedeem_T0 EpisodeID Erysipelas Erysipelas_T0 
    Erysipelas_naT0 eGFR Extractiedatum Geboortejaar dGeslacht Geslacht Glucose_nuchter 
    Glucose_nuchter_T0 HbA1c Huidaandoening_T0 dICPC Immuunsuppressiva Immuunsuppressiva_T0 
    ImmuunsuppressivaNaT0 Infectieuze_complicatie Infectieuze_complicatie_naT0 
    Infectieuze_complicatie_T0 Insulinen_analogen_T0 Insulinen_plusAnalogen Insulinen_plusAnalogenNaT0 
    Extractie_jaar JaarUitschrijven Jaar_diagnose_diabetes_alle LabUitslagACR LabUitslagACR_naT0 
    LabUitslagACR_T0 LabUitslagBMI LabUitslagBMI_naT0 LabUitslagBMI_T0 LabUitslagChol_HDLc 
    LabUitslagChol_HDLc_naT0 LabUitslagChol_HDLc_T0 LabUitslageGFR LabUitslageGFR_naT0 
    LabUitslageGFR_T0 LabUitslagGlucose_nuchter LabUitslagGlucose_nuchter_naT0 
    LabUitslagGlucose_nuchter_T0 Leeftijd_T0 Lichen_ruber_planus_T0 Lichen_ruber_planus 
    Lokale_antimycotica Lokale_antimycotica_T0 Lokale_antimycoticaNaT0 Medicatie_T0 
    Medicatie_diabetes_NaT0 Medicatie_diabetes_T0 Medicatie_NaT0 Neuropathie Neuropathie_T0 
    Omschrijving Onychomycose OnychomycoseNaT0 Onychomycose_T0 Overleden Overlijdensjaar 
    Paronychia_panaritium Paronychia_panaritium_T0 Paronychia_panaritium_naT0 
    Perifeer_arterieel_vaatlijden_T0 Perifeer_arterieel_vaatlijden Psoriasis Psoriasis_T0 Roken 
    Begindatum_Cellulitis Begindatum_Diabetes_alle Begindatum_Diabetes_type1 Begindatum_Diabetes_type2 
    Begindatum_Eczeem Begindatum_Enkeloedeem Begindatum_Erysipelas Begindatum_Lichen_ruber_planus 
    Begindatum_Neuropathie Begindatum_Onychomycose Begindatum_Paronychia_panaritium 
    Begindatum_Perifeer_arterieel_vaatlijden Begindatum_Psoriasis Begindatum_Tabaksmisbruik 
    Begindatum_Tinea_Pedis Begindatum_Ulcus Begindatum_Unguis_incarnatus 
    Begindatum_Veneuze_insufficientie BegindatumT90 Systemische_antimycotica 
    Systemische_antimycotica_T0 Systemische_antimycoticaNaT0 Tabaksmisbruik Tabaksmisbruik_T0 
    Tabaksmisbruik_NaT0 TijdTussenOnychomycose_Diabetes TijdTussenACR_Diabetes TijdTussenBMI_Diabetes 
    TijdTussenCellulitis_Diabetes TijdTussenChirurgische_ingreep_Diabetes TijdTussenchol_HDLc_Diabetes 
    TijdTussenEczeem_Diabetes TijdTusseneGFR_Diabetes TijdTussenEnkeloedeem_Diabetes 
    TijdTussenErysipelas_Diabetes TijdTussenExtractie_Overlijden TijdTussenGlucose_nuchter_Diabetes 
    TijdTussenLichen_ruber_planus_Diabetes TijdTussenNeuropathie_Diabetes 
    TijdTussenParonychia_panaritium_Diabetes TijdTussenPerifeer_arterieel_vaatlijden_Diabetes 
    TijdTussenPsoriasis_Diabetes TijdTussenTabaksmisbruik_Diabetes TijdTussenTinea_Pedis_Diabetes 
    TijdTussenUitschrijven_Overlijden TijdTussenUlcus_cruris_Diabetes TijdTussenUlcus_Diabetes 
    TijdTussenUnguis_incarnatus_Diabetes TijdTussenVeneuze_insufficientie_Diabetes 
    TijdTussenVerwijzing_Diabetes TijdTussenVoorschrift_Diabetes Tinea_PedisNaT0 Tinea_Pedis_T0 
    Tinea_Pedis dNHGMemo Ulcus UlcusNaT0 Ulcus_T0 Ulcus_cruris Ulcus_cruris_T0 Ulcus_cruris_naT0 
    Ulcus_Totaal_NaT0 Ulcus_Totaal_T0 Unguis_incarnatus_T0 Unguis_incarnatus Unguis_incarnatus_naT0 
    Veneuze_insufficientie Veneuze_insufficientie_T0 Verwezen_tweedelijn Verwijzing_T0 Verwijzing_naT0 
    WaardeAfwijkend = d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 
    d23 d24 d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 
    d48 d49 d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 
    d73 d74 d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 
    d98 d99 d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 
    d118 d119 d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 
    d138 d139 d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 
    d158 d159 d160 d161 d162 d163 d164 d165 d166 d167 d168 d169 d170 d171 d172 d173 d174 d175 d176 d177 
    d178 d179 d180 d181 d182 d183 d184) 
  /BY PATNR
  /DROP= d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 
    d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 
    d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73 d74 
    d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91 d92 d93 d94 d95 d96 d97 d98 d99 
    d100 d101 d102 d103 d104 d105 d106 d107 d108 d109 d110 d111 d112 d113 d114 d115 d116 d117 d118 d119 
    d120 d121 d122 d123 d124 d125 d126 d127 d128 d129 d130 d131 d132 d133 d134 d135 d136 d137 d138 d139 
    d140 d141 d142 d143 d144 d145 d146 d147 d148 d149 d150 d151 d152 d153 d154 d155 d156 d157 d158 d159 
    d160 d161 d162 d163 d164 d165 d166 d167 d168 d169 d170 d171 d172 d173 d174 d175 d176 d177 d178 d179 
    d180 d181 d182 d183 d184.
EXECUTE.

*/ Variabele gemaakt voor afwijkend HbA1c op T0 en na T0. 

DATASET ACTIVATE DataSet1.
COMPUTE Afwijkend_HbA1c_T0=(WaardeAfwijkend=1) AND (HbA1c_T0= 1).
EXECUTE.

COMPUTE Afwijkend_HbA1c_NaT0=(WaardeAfwijkend = 1) AND (LabUitslagHbA1c_naT0= 1).
EXECUTE.

*/ Per diagnostische bepaling een variabele gemaakt voor afwijkende labuitslag op T0. 
*/ Afwijkende ACR. 

COMPUTE Afwijkende_ACR_T0=(WaardeAfwijkend=1) AND (ACR_T0 = 1).
EXECUTE.

COMPUTE Afwijkende_ACR_NaT0=(WaardeAfwijkend=1) AND (LabUitslagACR_naT0 = 1).
EXECUTE.

*/ Variabele gemaakt voor afwijkend chol_HDLc op T0 en na T0. 

COMPUTE Afwijkend_chol_HDLc_T0=(WaardeAfwijkend=1) AND (chol_HDLc_T0 = 1).
EXECUTE.

COMPUTE Afwijkend_chol_HDLc_NaT0=(WaardeAfwijkend=1) AND (LabUitslagchol_HDLc_naT0= 1).
EXECUTE.

*/ Variabele gemaakt voor afwijkend Glucose_nuchter op T0 en na T0. 

COMPUTE Afwijkend_Glucose_nuchter_T0=(WaardeAfwijkend=1) AND (Glucose_nuchter_T0 = 1).
EXECUTE.

COMPUTE Afwijkend_Glucose_nuchter_NaT0=(WaardeAfwijkend=1) AND (LabUitslagGlucose_nuchter_naT0 = 1).
EXECUTE.

*/ Variabele gemaakt voor afwijkend BMI op T0 en na T0. 

COMPUTE Afwijkend_BMI_T0=(WaardeAfwijkend=1) AND (BMI = 1).
EXECUTE.

COMPUTE Afwijkend_BMI_NaT0=(WaardeAfwijkend=1) AND (LabUitslagBMI_naT0= 1).
EXECUTE.

* Variabele gemaakt voor afwijkende eGFR op T0 en na T0. 

COMPUTE Afwijkend_eGFR_T0=(WaardeAfwijkend=1) AND (eGFR_T0 = 1).
EXECUTE.

COMPUTE Afwijkend_eGFR_NaT0=(WaardeAfwijkend=1) AND (LabUitslageGFR_naT0 = 1).
EXECUTE.

*/ Variabelen voor afwijkende labuitslagen gerecodeerd naar 0/1 middels recode into same variables. 

RECODE Afwijkend_HbA1c_T0 Afwijkend_HbA1c_NaT0 Afwijkende_ACR_T0 Afwijkende_ACR_NaT0 
    Afwijkend_chol_HDLc_T0 Afwijkend_chol_HDLc_NaT0 Afwijkend_Glucose_nuchter_T0 
    Afwijkend_Glucose_nuchter_NaT0 Afwijkend_BMI_T0 Afwijkend_BMI_NaT0 Afwijkend_eGFR_T0 Afwijkend_eGFR_NaT0 (1=1) (ELSE=0).    
EXECUTE.

*/ Lab variabelen een duidelijk label gegeven. 

VARIABLE LABELS ACR 'ACR gedaan en geregistreerd (=1)'.
VARIABLE LABELS chol_HDLc 'chol_HDLc gedaan en geregistreerd (=1)'.
VARIABLE LABELS Glucose_nuchter 'Glucose_nuchter gedaan en geregistreerd (=1)'.
VARIABLE LABELS BMI 'BMI gedaan en geregistreerd (=1)'.
VARIABLE LABELS eGFR 'eGFR gedaan en geregistreerd (=1)'.
VARIABLE LABELS HbA1c 'HbA1c gedaan en geregistreerd (=1)'.
