* Encoding: UTF-8.

GET
  FILE='I:\ONDERZOEK\PROJECTEN\ELAN-DWH\20220511 - Ulcus - Roeland Watjer - '+
    'Ticket#272988\Complete data en syntax\Stap 3 - outcome variabelen plus analyses\Luise and '+
    'Sjaria (final)\Data View met baseline gegevens - gebruikt voor analyse Luise en Sjarai.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.
DATASET ACTIVATE DataSet1.

***************************************************
***************************************************
***************** ADDITIONAL DATA CLEANING *****************
***************************************************
***************************************************

*** Remove rows with diagnosis after deregistration date

USE ALL.
COMPUTE filter_$=(Begindatum_Onychomycose  > dUitschrijfdatum OR Begindatum_Tinea_Pedis > 
    dUitschrijfdatum OR Begindatum_Veneuze_insufficientie > dUitschrijfdatum OR 
    Begindatum_Perifeer_arterieel_vaatlijden > dUitschrijfdatum OR Begindatum_enkeloedeem > 
    dUitschrijfdatum OR Begindatum_Psoriasis > dUitschrijfdatum OR Begindatum_Lichen_ruber_planus > 
    dUitschrijfdatum OR Begindatum_Eczeem > dUitschrijfdatum OR Begindatum_Neuropathie > 
    dUitschrijfdatum OR Begindatum_Tabaksmisbruik > dUitschrijfdatum OR Begindatum_Unguis_incarnatus > 
    dUitschrijfdatum OR Begindatum_Ulcus > dUitschrijfdatum OR Begindatum_Erysipelas > dUitschrijfdatum 
    OR Begindatum_Cellulitis > dUitschrijfdatum OR Begindatum_Paronychia_panaritium > dUitschrijfdatum 
    OR Datum_Chirurgische_ingreep > dUitschrijfdatum OR DatumVerwijzing > dUitschrijfdatum).
VARIABLE LABELS filter_$ 'Begindatum_Onychomycose  > dUitschrijfdatum OR Begindatum_Tinea_Pedis '+
    '> dUitschrijfdatum OR Begindatum_Veneuze_insufficientie > dUitschrijfdatum OR '+
    'Begindatum_Perifeer_arterieel_vaatlijden > dUitschrijfdatum OR Begindatum_enkeloedeem > '+
    'dUitsc... (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF MISSING(filter_$).
EXECUTE.


*** Remove patients with negative ages and with ages greater than 100

FILTER OFF.
USE ALL.
SELECT IF (Leeftijd_T0 >= 0 AND Leeftijd_T0 <= 100).
EXECUTE.


*** Remove patients without starting date Diabetes

FILTER OFF.
USE ALL.
SELECT IF (~SYSMIS(Begindatum_Diabetes_alle)).
EXECUTE.

*/ Patients who did not have a certain event [exposure/outcome] during follow-up OR the event occured before DM diagnosis, 
will automatically be designated as having 0 months interval OR a negative interval time between the event and DM diagnosis
(as if they dropped-out so to speak) which is not true / correct. This was caused by the recoding process.
*/ For Cox analysis, every patient has to have a certain interval time. Therefore, to give them a fictitous interval required for Cox analysis
we had to recode this, chosing a fictitious 1500 months = 125 years follow-up, making the assumption that they did not have the exposure ever 
(which won't influence Cox results ???)
*/ This was done in 2 steps:

*** Recode entries with negative times between diagnosis riskfactor/complication and diabetes diagnosis

RECODE TijdTussenCellulitis_Diabetes TijdTussenChirurgische_ingreep_Diabetes 
    TijdTussenEczeem_Diabetes TijdTussenEnkeloedeem_Diabetes TijdTussenErysipelas_Diabetes 
    TijdTussenLichen_ruber_planus_Diabetes TijdTussenNeuropathie_Diabetes 
    TijdTussenOnychomycose_Diabetes TijdTussenParonychia_panaritium_Diabetes 
    TijdTussenPerifeer_arterieel_vaatlijden_Diabetes TijdTussenPsoriasis_Diabetes 
    TijdTussenTabaksmisbruik_Diabetes TijdTussenTinea_Pedis_Diabetes TijdTussenUlcus_Diabetes 
    TijdTussenUnguis_incarnatus_Diabetes TijdTussenVeneuze_insufficientie_Diabetes 
    TijdTussenVerwijzing_Diabetes TijdTussenUlcus_cruris_Diabetes (-1500 thru 0=1500).
EXECUTE.

*** Recode entries without diagnosis riskfactor/complication to time beween of 1500

RECODE TijdTussenCellulitis_Diabetes TijdTussenChirurgische_ingreep_Diabetes 
    TijdTussenEczeem_Diabetes TijdTussenEnkeloedeem_Diabetes TijdTussenErysipelas_Diabetes 
    TijdTussenLichen_ruber_planus_Diabetes TijdTussenNeuropathie_Diabetes 
    TijdTussenOnychomycose_Diabetes TijdTussenParonychia_panaritium_Diabetes 
    TijdTussenPerifeer_arterieel_vaatlijden_Diabetes TijdTussenPsoriasis_Diabetes 
    TijdTussenTabaksmisbruik_Diabetes TijdTussenTinea_Pedis_Diabetes TijdTussenUlcus_Diabetes 
    TijdTussenUnguis_incarnatus_Diabetes TijdTussenVeneuze_insufficientie_Diabetes 
    TijdTussenVerwijzing_Diabetes TijdTussenUlcus_cruris_Diabetes (MISSING=1500).
EXECUTE.


***************************************************
***************************************************
 ************ CREATE NEW VARIABLES *************
***************************************************
***************************************************

*/ Some interval variables were still missing, mainly for the variables / risk factors that were combined (e.g. ulcus cruris + diabetisch voetulcus)
based on overlap / GP coding reasons in clinical practice. The same was done for the binary variables (having or having not an exposure / outcome)
that also needed to be created because of the combinations made:

*** create new variable TijdTussenUlcusTotal_Diabetes  for time between all ulcers (leg + foot) and T0

COMPUTE TijdTussenUlcusTotal_Diabetes = MIN(TijdTussenUlcus_Diabetes, TijdTussenUlcus_cruris_Diabetes).
EXECUTE.

*** create new variable TijdTussenOnychomycoseTineaPedis_Diabetes for time between Onychomycose and Tinea Pedis (together) and T0

COMPUTE TijdTussenOnychomycoseTineaPedis_Diabetes = MIN(TijdTussenOnychomycose_Diabetes, TijdTussenTinea_Pedis_Diabetes).
EXECUTE.

*** create new variable TijdTussenCellulitisErysipelas_Diabetes for time between cellulitis and erysipelas (together) and T0

COMPUTE TijdTussenCellulitisErysipelas_Diabetes = MIN(TijdTussenCellulitis_Diabetes, TijdTussenErysipelas_Diabetes).
EXECUTE.

*** create status variables status_ulcer and status_onych_tinea for ulcer, and onychomycosis+tineapedis (needed for analyses of primary interest)

RECODE TijdTussenUlcusTotal_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_ulcer.
VARIABLE LABELS status_ulcer.
EXECUTE.

RECODE TijdTussenOnychomycoseTineaPedis_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_onych_tinea.
VARIABLE LABELS status_onych_tinea.
EXECUTE.

*** create status variables status_celullitis_erysipelas, status_unguis_incarnatus, and status_paronychia_panaritium for cellulitis+erysipelas, 
*** unguis incarnatus, panorychia panaritium (needed for analyses of secondary interest)

RECODE TijdTussenCellulitisErysipelas_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_celullitis_erysipelas.
VARIABLE LABELS status_celullitis_erysipelas.
EXECUTE.

RECODE TijdTussenUnguis_incarnatus_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_unguis_incarnatus.
VARIABLE LABELS status_unguis_incarnatus.
EXECUTE.

RECODE TijdTussenParonychia_panaritium_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_paronychia_panaritium.
VARIABLE LABELS status_unguis_incarnatus.
EXECUTE.

*/ The dataset used for this cleaning and analyes, did not contain a single start date for treatmets because of having a multitude of prescriptions for 
a multitude of patients. As a substitute, we took the day of diagnosis of onychomycosis as the start date of treatment, which was required for Cox analyses
Consider it a binary variable (treated vs not-treated) that a patient was exposed to at a certain point in time, counted from start of follow-up (i.e. not an actual interval)

***create variables TijdTussenAntimycotica_Diabetes, TijdTussenLokale_Antimycotica_Diabetes, and TijdTussenSystemische_Antimycotica_Diabetes 
*** with time between treatment and T0 (where we take time between onychomycoses and T0 as time for treatment)

COMPUTE TijdTussenAntimycotica_Diabetes = TijdTussenOnychomycose_Diabetes.
EXECUTE.

DO IF  (Anti_mycotica_NaT0  = 1).
RECODE TijdTussenAntimycotica_Diabetes (Lowest thru 1499=Copy) (ELSE=1500) INTO 
    TijdTussenAntimycotica_diabetes.
END IF.

DO IF  (Anti_mycotica_NaT0  = 0).
RECODE TijdTussenAntimycotica_Diabetes (Lowest thru 1499=1500) (ELSE=1500) INTO 
    TijdTussenAntimycotica_diabetes.
END IF.
EXECUTE.

COMPUTE TijdTussenLokale_Antimycotica_Diabetes = TijdTussenOnychomycose_Diabetes.
EXECUTE.

DO IF  (Lokale_antimycoticaNaT0 = 1).
RECODE TijdTussenLokale_Antimycotica_Diabetes (Lowest thru 1499=Copy) (ELSE=1500) INTO 
    TijdTussenLokale_Antimycotica_Diabetes.
END IF.

DO IF  (Lokale_antimycoticaNaT0 = 0).
RECODE TijdTussenLokale_Antimycotica_Diabetes (Lowest thru 1499=1500) (ELSE=1500) INTO 
    TijdTussenLokale_Antimycotica_Diabetes.
END IF.
EXECUTE.

COMPUTE TijdTussenSystemische_Antimycotica_Diabetes = TijdTussenOnychomycose_Diabetes.
EXECUTE.

DO IF  (Systemische_antimycoticaNaT0  = 1).
RECODE TijdTussenSystemische_Antimycotica_Diabetes (Lowest thru 1499=Copy) (ELSE=1500) INTO 
    TijdTussenSystemische_Antimycotica_Diabetes.
END IF.

DO IF  (Systemische_antimycoticaNaT0  = 0).
RECODE TijdTussenSystemische_Antimycotica_Diabetes (Lowest thru 1499=1500) (ELSE=1500) INTO 
    TijdTussenSystemische_Antimycotica_Diabetes.
END IF.
EXECUTE.

*** create status variables status_veneuze_insufficientie, status_perifeer_arterieel_vaatlijden, status_enkel_oedeem, status_psoriasis, 
*** status_lrp, status_eczeem, status_neuropathie, status_tabaksmisbruik for each risk factor (needed for analyses of secondary interest)

RECODE TijdTussenVeneuze_insufficientie_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_veneuze_insufficientie.
VARIABLE LABELS status_veneuze_insufficientie.
EXECUTE.

RECODE TijdTussenPerifeer_arterieel_vaatlijden_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_perifeer_arterieel_vaatlijden.
VARIABLE LABELS status_perifeer_arterieel_vaatlijden.
EXECUTE.

RECODE TijdTussenEnkeloedeem_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_enkel_oedeem.
VARIABLE LABELS status_enkel_oedeem.
EXECUTE.

RECODE TijdTussenPsoriasis_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_psoriasis.
VARIABLE LABELS status_psoriasis.
EXECUTE.

RECODE TijdTussenLichen_ruber_planus_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_lrp.
VARIABLE LABELS status_lrp.
EXECUTE.

RECODE TijdTussenEczeem_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_eczeem.
VARIABLE LABELS status_eczeem.
EXECUTE.

RECODE TijdTussenNeuropathie_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_neuropathie.
VARIABLE LABELS status_neuropathie.
EXECUTE.

RECODE TijdTussenTabaksmisbruik_Diabetes (LOWEST thru 1499=1) (ELSE=0) INTO 
    status_tabaksmisbruik.
VARIABLE LABELS status_tabaksmisbruik.
EXECUTE.


***************************************************
***************************************************
******************* ANALYSIS **********************
************** (PRIMARY INTEREST) ****************
***************************************************
***************************************************

*** Univariate model: Effect of onychomycosis on the development of ulcers ***
*** Covariate: Onychomycosis
*** Outcome: Ulcer

TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_ 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis on the development of ulcers using time interaction model
(NB not directly possible via menu options, so put in manually! = third row)**

TIME PROGRAM.
COMPUTE T_COV_ = 1*(T_>TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction = T_*(T_>TijdTussenOnychomycose_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_ T_interaction
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

*** Univariate model: Effect of onychomycosis + Tinea pedis on the development of ulcers ***
*** Covariate: Onychomycosis + Tinea pedis
*** Outcome: Ulcer

TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycoseTineaPedis_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_ 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis+tinea pedis on the development of ulcers **

TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycoseTineaPedis_Diabetes).
COMPUTE T_interaction = T_*(T_>TijdTussenOnychomycoseTineaPedis_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_ T_interaction
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and antimycotic treatment on the development of ulcers ***
*** Covariates: Onychomycosis and antimycotics
*** Outcome: Ulcer

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenAntimycotica_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and antimycotic treatment on the development of ulcers **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenAntimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenAntimycotica_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and local antimycotic treatment on the development of ulcers ***
*** Covariates: Onychomycosis and local antimycotics
*** Outcome: Ulcer

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenLokale_Antimycotica_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and local antimycotic treatment on the development of ulcers **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenLokale_Antimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenLokale_Antimycotica_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and systemic antimycotic treatment on the development of ulcers ***
*** Covariates: Onychomycosis and systemic antimycotics
*** Outcome: Ulcer

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and systemic antimycotic treatment on the development of ulcers **

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Univariate model: Effect of onychomycosis on getting a referral ***
*** Covariate: Onychomycosis
*** Outcome: Referral

TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COXREG   TijdTussenVerwijzing_Diabetes
  /STATUS=Verwijzing_naT0(1)
  /METHOD=ENTER T_COV_ 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis on the getting a referral **
    
TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction = T_*(T_>TijdTussenOnychomycose_Diabetes).
COXREG   TijdTussenVerwijzing_Diabetes
  /STATUS=Verwijzing_naT0(1)
  /METHOD=ENTER T_COV_ T_interaction
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and antimycotic treatment on getting a referral ***
*** Covariate: Onychomycosis and antimycotics
*** Outcome: Referral

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenAntimycotica_Diabetes).
COXREG   TijdTussenVerwijzing_Diabetes
  /STATUS=Verwijzing_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and antimycotic treatment on the getting a referral **

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenAntimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenAntimycotica_Diabetes).
COXREG   TijdTussenVerwijzing_Diabetes
  /STATUS=Verwijzing_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and local antimycotic treatment on getting a referral ***
*** Covariate: Onychomycosis and local antimycotics
*** Outcome: Referral

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenLokale_Antimycotica_Diabetes).
COXREG   TijdTussenVerwijzing_Diabetes
  /STATUS=Verwijzing_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and local antimycotic treatment on the getting a referral **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenLokale_Antimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenLokale_Antimycotica_Diabetes).
COXREG   TijdTussenVerwijzing_Diabetes
  /STATUS=Verwijzing_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and systemic antimycotic treatment on getting a referral ***
*** Covariates: Onychomycosis and systemic antimycotics
*** Outcome: Referral

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COXREG   TijdTussenVerwijzing_Diabetes
  /STATUS=Verwijzing_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and systemic antimycotic treatment on the getting a referral **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COXREG   TijdTussenVerwijzing_Diabetes
  /STATUS=Verwijzing_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Univariate model: Effect of onychomycosis on getting a surgical intervention ***
*** Covariate: Onychomycosis
*** Outcome: Surgical intervention

TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COXREG   TijdTussenChirurgische_ingreep_Diabetes
  /STATUS=Chirurgische_ingreep_naT0(1)
  /METHOD=ENTER T_COV_ 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis on the getting a surgical intervention **
    
TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COXREG   TijdTussenChirurgische_ingreep_Diabetes
  /STATUS=Chirurgische_ingreep_naT0(1)
  /METHOD=ENTER T_COV_ T_interaction
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and antimycotic treatment on getting a surgical intervention ***
*** Covariates: Onychomycosis and antimycotics
*** Outcome: Surgical intervention

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenAntimycotica_Diabetes).
COXREG   TijdTussenChirurgische_ingreep_Diabetes
  /STATUS=Chirurgische_ingreep_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and antimycotic treatment on the getting a surgical intervention **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenAntimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenAntimycotica_Diabetes).
COXREG   TijdTussenChirurgische_ingreep_Diabetes
  /STATUS=Chirurgische_ingreep_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and local antimycotic treatment on getting a surgical intervention ***
*** Covariates: Onychomycosis and local antimycotics
*** Outcome: Surgical intervention

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenLokale_Antimycotica_Diabetes).
COXREG   TijdTussenChirurgische_ingreep_Diabetes
  /STATUS=Chirurgische_ingreep_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and local antimycotic treatment on the getting a surgical intervention **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenLokale_Antimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenLokale_Antimycotica_Diabetes).
COXREG   TijdTussenChirurgische_ingreep_Diabetes
  /STATUS=Chirurgische_ingreep_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Multivariate model: Effect of onychomycosis and local antimycotic treatment on getting a surgical intervention ***
*** Covariates: Onychomycosis and local antimycotics
*** Outcome: Surgical intervention

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COXREG   TijdTussenChirurgische_ingreep_Diabetes
  /STATUS=Chirurgische_ingreep_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis and systemic antimycotic treatment on the getting a surgical intervention **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1* (T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenSystemische_Antimycotica_Diabetes).
COXREG   TijdTussenChirurgische_ingreep_Diabetes
  /STATUS=Chirurgische_ingreep_naT0(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_interaction_1 T_interaction_2
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


***************************************************
***************************************************
******************* ANALYSIS **********************
************ (SECONDARY INTEREST) ***************
***************************************************
***************************************************

*** Multivariate model: Effect of all risk factors on the development of ulcers ***
*** Covariates: Onychomycosis, Venous insufficiency, Peripheral arterial disease, ankle edema, psoriasis, lichen ruber planus, eczema, neuropathy, tobocco use
*** Outcome: Ulcer

TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1 * (T_ > TijdTussenVeneuze_insufficientie_Diabetes).
COMPUTE T_COV_3 = 1 * (T_ > TijdTussenPerifeer_arterieel_vaatlijden_Diabetes).
COMPUTE T_COV_4 = 1* (T_ > TijdTussenEnkeloedeem_Diabetes).
COMPUTE T_COV_5 = 1* (T_ > TijdTussenPsoriasis_Diabetes).
COMPUTE T_COV_6 = 1* (T_ > TijdTussenLichen_ruber_planus_Diabetes).
COMPUTE T_COV_7 = 1* (T_ > TijdTussenEczeem_Diabetes).
COMPUTE T_COV_8 = 1* (T_ > TijdTussenNeuropathie_Diabetes).
COMPUTE T_COV_9 = 1* (T_ > TijdTussenTabaksmisbruik_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_COV_3 T_COV_4 T_COV_5 T_COV_6 T_COV_7 T_COV_8 T_COV_9
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of all risk factors on the development of ulcers **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1 * (T_ > TijdTussenVeneuze_insufficientie_Diabetes).
COMPUTE T_COV_3 = 1 * (T_ > TijdTussenPerifeer_arterieel_vaatlijden_Diabetes).
COMPUTE T_COV_4 = 1* (T_ > TijdTussenEnkeloedeem_Diabetes).
COMPUTE T_COV_5 = 1* (T_ > TijdTussenPsoriasis_Diabetes).
COMPUTE T_COV_6 = 1* (T_ > TijdTussenLichen_ruber_planus_Diabetes).
COMPUTE T_COV_7 = 1* (T_ > TijdTussenEczeem_Diabetes).
COMPUTE T_COV_8 = 1* (T_ > TijdTussenNeuropathie_Diabetes).
COMPUTE T_COV_9 = 1* (T_ > TijdTussenTabaksmisbruik_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenVeneuze_insufficientie_Diabetes).
COMPUTE T_interaction_3 = T_*(T_ > TijdTussenPerifeer_arterieel_vaatlijden_Diabetes).
COMPUTE T_interaction_4 = T_*(T_ > TijdTussenEnkeloedeem_Diabetes).
COMPUTE T_interaction_5 = T_*(T_ > TijdTussenPsoriasis_Diabetes).
COMPUTE T_interaction_6 = T_*(T_ > TijdTussenLichen_ruber_planus_Diabetes).
COMPUTE T_interaction_7 = T_*(T_ > TijdTussenEczeem_Diabetes).
COMPUTE T_interaction_8 = T_*(T_ > TijdTussenNeuropathie_Diabetes).
COMPUTE T_interaction_9 = T_*(T_ > TijdTussenTabaksmisbruik_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_COV_3 T_COV_4 T_COV_5 T_COV_6 T_COV_7 T_COV_8 T_COV_9 
  T_interaction_1 T_interaction_2 T_interaction_3 T_interaction_4 T_interaction_5 T_interaction_6 T_interaction_7 T_interaction_8 T_interaction_9 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption with a log of time for model for the effect of all risk factors on the development of ulcers **
    
TIME PROGRAM.
COMPUTE T_COV_1 = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_2 = 1 * (T_ > TijdTussenVeneuze_insufficientie_Diabetes).
COMPUTE T_COV_3 = 1 * (T_ > TijdTussenPerifeer_arterieel_vaatlijden_Diabetes).
COMPUTE T_COV_4 = 1* (T_ > TijdTussenEnkeloedeem_Diabetes).
COMPUTE T_COV_5 = 1* (T_ > TijdTussenPsoriasis_Diabetes).
COMPUTE T_COV_6 = 1* (T_ > TijdTussenLichen_ruber_planus_Diabetes).
COMPUTE T_COV_7 = 1* (T_ > TijdTussenEczeem_Diabetes).
COMPUTE T_COV_8 = 1* (T_ > TijdTussenNeuropathie_Diabetes).
COMPUTE T_COV_9 = 1* (T_ > TijdTussenTabaksmisbruik_Diabetes).
COMPUTE T_interaction_1 = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_interaction_2 = T_*(T_ > TijdTussenVeneuze_insufficientie_Diabetes).
COMPUTE T_interaction_3 = T_*(T_ > TijdTussenPerifeer_arterieel_vaatlijden_Diabetes).
COMPUTE T_interaction_4 = LN(T_)*(T_ > TijdTussenEnkeloedeem_Diabetes).
COMPUTE T_interaction_5 = T_*(T_ > TijdTussenPsoriasis_Diabetes).
COMPUTE T_interaction_6 = T_*(T_ > TijdTussenLichen_ruber_planus_Diabetes).
COMPUTE T_interaction_7 = T_*(T_ > TijdTussenEczeem_Diabetes).
COMPUTE T_interaction_8 = LN(T_)*(T_ > TijdTussenNeuropathie_Diabetes).
COMPUTE T_interaction_9 = T_*(T_ > TijdTussenTabaksmisbruik_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_1 T_COV_2 T_COV_3 T_COV_4 T_COV_5 T_COV_6 T_COV_7 T_COV_8 T_COV_9 
  T_interaction_1 T_interaction_2 T_interaction_3 T_interaction_4 T_interaction_5 T_interaction_6 T_interaction_7 T_interaction_8 T_interaction_9 
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** New model for all risk factors, now with the newly calculated time dependent covariate for ankle edema (enkel oedeem) and neuropathy (neuropathy)
because their PH assumptions were violated.
    
TIME PROGRAM.
COMPUTE T_COV_onych = 1 * (T_ > TijdTussenOnychomycose_Diabetes).
COMPUTE T_COV_veneuze = 1 * (T_ > TijdTussenVeneuze_insufficientie_Diabetes).
COMPUTE T_COV_perifeer = 1 * (T_ > TijdTussenPerifeer_arterieel_vaatlijden_Diabetes).
COMPUTE T_COV_enkel = 1* (T_ > TijdTussenEnkeloedeem_Diabetes).
COMPUTE T_interaction_enkel = LN(T_)*(T_ > TijdTussenEnkeloedeem_Diabetes).
COMPUTE T_COV_psoriasis = 1* (T_ > TijdTussenPsoriasis_Diabetes).
COMPUTE T_COV_lichen = 1* (T_ > TijdTussenLichen_ruber_planus_Diabetes).
COMPUTE T_COV_eczeem = 1* (T_ > TijdTussenEczeem_Diabetes).
COMPUTE T_COV_neuro = 1* (T_ > TijdTussenNeuropathie_Diabetes).
COMPUTE T_interaction_neuro = LN(T_)*(T_ > TijdTussenNeuropathie_Diabetes).
COMPUTE T_COV_tabak = 1* (T_ > TijdTussenTabaksmisbruik_Diabetes).
COXREG   TijdTussenUlcusTotal_Diabetes
  /STATUS=status_ulcer(1)
  /METHOD=ENTER T_COV_onych T_COV_veneuze T_COV_perifeer T_COV_enkel T_interaction_enkel
  T_COV_psoriasis T_COV_lichen T_COV_eczeem T_COV_neuro T_interaction_neuro T_COV_tabak
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Univariate model: Effect of onychomycosis on the development of cellulitis and erysipelas ***
*** Covariate: Onychomycosis
*** Outcome: Cellulitis+Erysipelas
 
TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COXREG TijdTussenCellulitisErysipelas_Diabetes
  /STATUS=status_celullitis_erysipelas(1)
  /METHOD=ENTER T_COV_
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis on the development of cellulitis and erysipelas **
    
TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_interaction = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COXREG TijdTussenCellulitisErysipelas_Diabetes
  /STATUS=status_celullitis_erysipelas(1)
  /METHOD=ENTER T_COV_ T_interaction
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).


*** Univariate model: Effect of onychomycosis on the development of unguis incarnatus ***
*** Covariate: Onychomycosis
*** Outcome: Unguis incarnatus
 
TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COXREG TijdTussenUnguis_incarnatus_Diabetes
  /STATUS=status_unguis_incarnatus(1)
  /METHOD=ENTER T_COV_
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

** Testing PH Assumption for model for the effect of onychomycosis on the development of unguis incarnatus **

TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_interaction = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COXREG TijdTussenUnguis_incarnatus_Diabetes
  /STATUS=status_unguis_incarnatus(1)
  /METHOD=ENTER T_COV_ T_interaction
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

    
*** Univariate model: Effect of onychomycosis on the development of panorychia panaritium ***
*** Covariate: Onychomycosis
*** Outcome: Panorychia panaritium
 
TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COXREG TijdTussenParonychia_panaritium_Diabetes
  /STATUS=status_paronychia_panaritium(1)
  /METHOD=ENTER T_COV_
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).

* Testing PH Assumption for model for the effect of onychomycosis on the development of paronychia panaritium **
    
TIME PROGRAM.
COMPUTE T_COV_ = 1 * (T_ > TijdTussenOnychomycose_Diabetes ).
COMPUTE T_interaction = T_*(T_ > TijdTussenOnychomycose_Diabetes).
COXREG TijdTussenParonychia_panaritium_Diabetes
  /STATUS=status_paronychia_panaritium(1)
  /METHOD=ENTER T_COV_ T_interaction
  /PRINT=CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20).



