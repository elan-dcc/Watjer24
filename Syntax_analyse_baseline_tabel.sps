* Encoding: UTF-8.
*/ Analyse van gegevens welke ingevuld zullen worden in de baseline tabel. 
*/ DESCRIPTIVES. Deel 1= totale cohort. Deel 2= opgedeeld in onychomycose wel/niet. 

GET
  FILE='I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - Ticket#272988\SPSS '+
    'analyse_Kim\Hoofdmap overdracht\Complete data en syntax\Stap 1 - syntax en data voor '+
    'baseline\Data View met baseline gegevens.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.

*/ Sommige patienten hebben een follow up van meer dan 100 jaar tgv diagnose diabetes 1900 + geen uitschrijfdatum/niet geregistreerd als overleden. 
*/ Het voorgaande is sowieso het geval voor patienten met een begindatum van DM =< 1944. Op basis hiervan patienten met beginddatum =<1944 geexclueerd van de analyse middel select cases if Jaar_diagnose_diabetes_alle >= 1944, delete unselected cases.

DATASET ACTIVATE DataSet1.
FILTER OFF.
USE ALL.
SELECT IF (Jaar_diagnose_diabetes_alle >= 1944).
EXECUTE.

*/ Alsnog veel patiënten waarbij geboortedatum=begindatum diabetes mellitus. Gecontroleerd hoeveel middels het aanmaken van een nieuwe variabele.

COMPUTE Geboortedatum_is_datumdiabetes=Geboortejaar = Jaar_diagnose_diabetes_alle.
EXECUTE.

*/ PM to self: frequency is 47, dus ook deze laatste patienten geexcludeerd van onze analyse ivm een onrealistische startdatum van diabetes middels select cases if Geboortedatum_is_datumdiabetes=0, delect unselected cases 

FILTER OFF.
USE ALL.
SELECT IF (Geboortedatum_is_datumdiabetes = 0).
EXECUTE.

*/ Bekeken hoeveel patienten geen registratie hebben van overlijden of uitschrijven maar wel eigenlijk overleden zouden moeten zijn ahv geboortejaar.  
*/ Er vanuit gegaan dat zodra iemand een geboortejaar <1922 heeft (dus 100j oud zou zijn) overleden zou moeten zijn. 

COMPUTE Overleden_zonder_registratie=(SYSMIS(dUitschrijfdatum)) AND (Overleden=0) AND (Geboortejaar < 1922).
EXECUTE.

*/ Patienten waarbij Overleden_zonder_registratie=1 gecodeerd als toch overleden.

DATASET ACTIVATE DataSet 1.
IF (Overleden_zonder_registratie=1) Overleden=1.

*/ SPSS geeft de melding 'Expecting word or = sign. Found 1' maar als je de opdracht controleert dan zie je dat het gelukt is (namelijk: alle patienten met Overleden_zonder_registratie=1 hebben nu ook een 1 voor de variabele Overleden'. 
*/ Na de bovenstaan de aanpassingen heeft PATNR in DataSet1 een frequency van 49978. Op basis van deze 49978 patienten de baselinetabel opgesteld middels onderstaande analyze. 

*/ Deel 1 (kolom 1 van de baseline tabel) 

FREQUENCIES VARIABLES=Overleden Diabetes_type_1_ja_nee Diabetes_type_2_ja_nee Geslacht Onychomycose_T0 
    Afwijkend_BMI_T0 Tinea_Pedis_T0 Veneuze_insufficientie_T0 Perifeer_arterieel_vaatlijden_T0 Enkeloedeem_T0 
    Psoriasis_T0 Lichen_ruber_planus_T0 Eczeem_T0 Huidaandoening_T0 Neuropathie_T0 Roken Unguis_incarnatus_T0 
    Ulcus_T0 Erysipelas_T0 Cellulitis_T0 Paronychia_panaritium_T0 Ulcus_cruris_T0 Chirurgische_ingreep_T0 Verwijzing_T0 Afwijkend_HbA1c_T0 Afwijkend_chol_HDLc_T0 Afwijkend_Glucose_nuchter_T0 Afwijkende_ACR_T0
    Afwijkende_ACR_T0 Insulinen_analogen_T0 Immuunsuppressiva_T0 Anti_mycotica_T0 Medicatie_diabetes_T0 Lokale_antimycotica_T0 Systemische_antimycotica_T0 Complicatie_anderzins_T0 Complicatie_enige_vorm_T0
  /ORDER=ANALYSIS.

*/ Analyze, descriptive statistics descriptives voor de gemiddeldes van de numerieke (demografische) variabelen. 

DESCRIPTIVES VARIABLES=Leeftijd_T0
  /STATISTICS=MEAN STDDEV MIN MAX.

*/ Independent sample T-test om het gemiddelde v.d. numerieke variabelen tussen diabeten zonder onychomcose (onychomycsose=0 is group1) te vergelijken met diabeten met onychomycose (ony=1 is group 2). 

T-TEST GROUPS=Onychomycose_T0(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=Leeftijd_T0 LabUitslagACR_T0 LabUitslagChol_HDLc_T0 LabUitslagGlucose_nuchter_T0 LabUitslageGFR_T0 LabUitslagHbA1c_T0
  /CRITERIA=CI(.95).

*/ Cross tabs voor de risicofactoren c.q. de frequenties van categorische variabelen die aangeven of de diabeten in het cohort risicofactoren hebben voor het ontwikkelen van een ulcus.
*/ Oftewel frequentie bepaling van de comorbiditeit op baseline. 
*/ Onder het tabblad cells percentages of row colum and total aangeven zodat de percentages per groep worden berekend van het totaal.
*/ Onder het tabblad statistics Chi square kiezen zodat SPSS uitrekent of de verschillen tussen patienten met en zonder onychomycose op baseline significant zijn. 

CROSSTABS
  /TABLES= Tinea_Pedis_T0 Veneuze_insufficientie_T0 Perifeer_arterieel_vaatlijden_T0 Enkeloedeem_T0 Psoriasis_T0 Lichen_ruber_planus_T0 Eczeem_T0 Huidaandoening_T0 Neuropathie_T0 
  Paronychia_panaritium_T0 Infectieuze_complicatie_T0 Medicatie_diabetes_T0 Insulinen_analogen_T0 Immuunsuppressiva_T0 Anti_mycotica_T0 Lokale_antimycotica_T0
  Systemische_antimycotica_T0 Afwijkend_chol_HDLc_T0 Afwijkend_Glucose_nuchter_T0 Afwijkend_BMI_T0 Afwijkend_HbA1c_T0 Afwijkende_ACR_T0 Afwijkend_eGFR_T0 BY Onychomycose_T0
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ 
  /CELLS=COUNT ROW COLUMN TOTAL 
  /COUNT ROUND CELL.

*/ Cross tabs voor de uitkomstmaten c.q. voor de frequenties van categorische variabelen die aangeven of een diabetes patient reeds een van de uitkomsten heeft doorgemaakt. 

CROSSTABS
  /TABLES=Unguis_incarnatus_T0 Ulcus_T0 Erysipelas_T0 Cellulitis_T0 Infectieuze_complicatie_T0 
    Ulcus_cruris_T0 Chirurgische_ingreep_T0 Verwijzing_T0 Complicatie_anderzins_T0 Complicatie_enige_vorm_T0 BY Onychomycose_T0
  /FORMAT=AVALUE TABLES
   /STATISTICS=CHISQ 
  /CELLS=COUNT ROW COLUMN TOTAL 
  /COUNT ROUND CELL.

*/ Analyze descriptives statistics descriptives om de gemiddeldes van diagnostische bepalingen voor het totale cohort vast te stellen. 

DESCRIPTIVES VARIABLES=LabUitslagHbA1c_T0 LabUitslageGFR_T0 LabUitslagBMI_T0 LabUitslagGlucose_nuchter_T0 LabUitslagChol_HDLc_T0 LabUitslagACR_T0
  /STATISTICS=MEAN STDDEV MIN MAX.

*/ Independent sample T-test om het verschil in gemiddelde diagnostische bepalingen tussen diabeten zonder onychomcose (onychomycsose=0 is group1) ter vergelijken met diabeten met onychomycose (ony=1 is group 2). 
*/ BMI ook ontvangen als diagnostische bepaling. Ook de gemiddelden van BMI met een independent sample T-test geanalyseerd. 

T-TEST GROUPS=Onychomycose_T0(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=LabUitslagHbA1c_T0 LabUitslageGFR_T0 LabUitslagBMI_T0 LabUitslagGlucose_nuchter_T0 LabUitslagChol_HDLc_T0 LabUitslagACR_T0
  /CRITERIA=CI(.95).


