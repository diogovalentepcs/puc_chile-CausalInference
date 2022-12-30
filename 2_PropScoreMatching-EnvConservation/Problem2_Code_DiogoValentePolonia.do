

//				Problem Set 2 : Matching			//
//				Diogo Valente Polónia				//
//					  24/11/2022					//


clear all

// Directorio
cd "/Users/diogovalentepolonia/Projects/PoliticasAmbientales/P2"
	
// Base de Datos
use "landuse.dta"
describe

*-------------------------------------------------------------------*
*							PREGUNTA 1								*
*-------------------------------------------------------------------*

//	Verificacion si existen diferencias en cada una de las variables observables (pre_acres, income y popdensity) entre las comunas que participaron en el progroma y las que no, a traves del t-test

local variables pre_acres income popdensity
foreach variable of local variables { 
	di "Analisis de la variable `variable'" 
	ttest `variable', by(consprog)
} 

//	Analisis con nivel de significancia: 5% (alfa)
//	pre_acres:			rechaza H0 (Pr(|T| > |t|) = 0.0000 < 0.05)
//	income: 			rechaza H0 (Pr(|T| > |t|) = 0.0000 < 0.05)
//	popdensity: 		rechaza H0 (Pr(|T| > |t|) = 0.0000 < 0.05)

// Conclusión: Como todas las variables  rechazan la hipótesis nula (valor p < alfa), con valores p's muy bajos (0 para cuatro casas decimales), entonces hay pruebas estadísticamente significativas de que la media de estas variables sea diferente entre los grupos tratados y no tratados (comunas que no participaron en el programa). Así que se puede concluir que la assignación de tratamiento no fué aleatoria. 

*-------------------------------------------------------------------*
*							PREGUNTA 2								*
*-------------------------------------------------------------------*

graph twoway (scatter pre_acres income) (lfit pre_acres income)
graph twoway (scatter pre_acres popdensity) (lfit pre_acres popdensity)

reg pre_acres income popdensity


//       Source |       SS           df       MS      Number of obs   =       500
// -------------+----------------------------------   F(2, 497)       >  99999.00
//        Model |  1.05564405         2  .527822027   Prob > F        =    0.0000
//     Residual |  1.9805e-14       497  3.9849e-17   R-squared       =    1.0000
// -------------+----------------------------------   Adj R-squared   =    1.0000
//        Total |  1.05564405       499  .002115519   Root MSE        =    6.3e-09
// 
// ------------------------------------------------------------------------------
//    pre_acres | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//       income |   .0000125   8.75e-14  1.4e+08   0.000     .0000125    .0000125
//   popdensity |     -.0005   7.85e-12 -6.4e+07   0.000       -.0005      -.0005
//        _cons |         .1   1.44e-09  7.0e+07   0.000           .1          .1
// ------------------------------------------------------------------------------

//	Conclusión: 
//	De los gráficos de dispersión se desprende que existe una relación relevante entre el income/popdensity y pre_acres, lo que indica que la participación en el programa de conservación no fue tan buena como si hubiera sido realizada en forma aleatoria condicional sobre el ingreso y la densidad poblacional. En ese caso, no debería haber ninguna relación entre estas variables (si el programa hubiera sido asignado de manera aleatoria, la línea de base de bosques nada tendría que ver con las covariables).
//	Cuando hacemos una regresión de pre_acres por la renta y la densidad de población, encontramos resultados significativos para los coeficientes de estas variables, lo que indica además que la participación no es tan buena como hubiera sido con asignación aleatoria condicional (aunque los coeficientes sean pequeños)


*-------------------------------------------------------------------*
*							PREGUNTA 3								*
*-------------------------------------------------------------------*

//	Y (outcome):	post_acres
//	T (treatment):	consprog
//  Controles:		pre_acres, income, popdensity

global controles "pre_acres income popdensity" 

//	Estimación del impacto causal a traves de una regresión lineal

reg post_acres consprog $controles

//       Source |       SS           df       MS      Number of obs   =       500
// -------------+----------------------------------   F(3, 496)       =    102.48
//        Model |  .753414493         3  .251138164   Prob > F        =    0.0000
//     Residual |  1.21550503       496  .002450615   R-squared       =    0.3827
// -------------+----------------------------------   Adj R-squared   =    0.3789
//        Total |  1.96891952       499  .003945731   Root MSE        =     .0495
// 
// ------------------------------------------------------------------------------
//   post_acres | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//   consprog |    .045641   .0055434     8.23   0.000     .0347496    .0565324
//    pre_acres |          0  (omitted)
//       income |   .0000123   7.25e-07    17.03   0.000     .0000109    .0000138
//   popdensity |  -.0003914   .0000714    -5.48   0.000    -.0005317   -.0002512
//        _cons |   .0900096   .0112966     7.97   0.000     .0678144    .1122048
// ------------------------------------------------------------------------------


//	Conclusión:
//	El coeficiente de la variable de "consrog" de la regresion, para un nivel de significancia de 5%, es estadísticamente significativo, ya que el valor p (0.0%) es menor que el nivel de significancia (5%). Con esta regresion se podría concluir, entonces, que la participación en el programa de conservación aumenta la porcentaje de conservación de bosques en 0.045% (o sea, una comuna con 10% de conservación, depués de pariticpar teria 10.045% de area conservada). Sin embargo, como se identificaran diferencias significativas entre los grupos y  hay evidencia de que el tratamiento no fue aleatorio, entonces esta evaluación no tiene validez interna.

*-------------------------------------------------------------------*
*							PREGUNTA 4								*
*-------------------------------------------------------------------*

//	Estimación del Average Treatment Effect (ATE) a traves de matching para el vecino más cercano (N Neighbor = 1)

teffects nnmatch (post_acres $controles) (consprog), ate nneighbor(1)

// Results:

// note: popdensity omitted because of collinearity.
// ------------------------------------------------------------------------------
// Treatment-effects estimation                   Number of obs      =        500
// Estimator      : nearest-neighbor matching     Matches: requested =          1
// Outcome model  : matching                                     min =          1
// Distance metric: Mahalanobis                                  max =          1
// ------------------------------------------------------------------------------
//              |              AI robust
//   post_acres | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
// ATE          |
//     consprog |
//    (1 vs 0)  |   .0410994   .0076203     5.39   0.000     .0261639    .0560349
// ------------------------------------------------------------------------------

//	Estimación del Average Treatment Effect (ATE) a traves de matching para los 4 vecinos más cercanos (N Neighbor = 4)

teffects nnmatch (post_acres $controles) (consprog), ate nneighbor(4)

// Results:

// note: popdensity omitted because of collinearity.
// ------------------------------------------------------------------------------
// Treatment-effects estimation                   Number of obs      =        500
// Estimator      : nearest-neighbor matching     Matches: requested =          4
// Outcome model  : matching                                     min =          4
// Distance metric: Mahalanobis                                  max =          4
// ------------------------------------------------------------------------------
//              |              AI robust
//   post_acres | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
// ATE          |
//     consprog |
//    (1 vs 0)  |   .0393229    .006515     6.04   0.000     .0265537     .052092
// ------------------------------------------------------------------------------

//	Estimación del Average Treatment Effect on Treated (ATT) a traves de matching para el vecino más cercano (N Neighbor = 1)

teffects nnmatch (post_acres $controles) (consprog), atet nneighbor(1)

// note: popdensity omitted because of collinearity.
// ------------------------------------------------------------------------------
// Treatment-effects estimation                   Number of obs      =        500
// Estimator      : nearest-neighbor matching     Matches: requested =          1
// Outcome model  : matching                                     min =          1
// Distance metric: Mahalanobis                                  max =          1
// ------------------------------------------------------------------------------
//              |              AI robust
//   post_acres | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
// ATET         |
//     consprog |
//    (1 vs 0)  |   .0363754   .0098018     3.71   0.000     .0171642    .0555866
// ------------------------------------------------------------------------------

//	Estimación del Average Treatment Effect on Treated (ATT) a traves de matching para los 4 vecinos más cercanos (N Neighbor = 4)

teffects nnmatch (post_acres $controles) (consprog), atet nneighbor(4)

// note: popdensity omitted because of collinearity.
// ------------------------------------------------------------------------------
// Treatment-effects estimation                   Number of obs      =        500
// Estimator      : nearest-neighbor matching     Matches: requested =          4
// Outcome model  : matching                                     min =          4
// Distance metric: Mahalanobis                                  max =          4
// ------------------------------------------------------------------------------
//              |              AI robust
//   post_acres | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
// ATET         |
//     consprog |
//    (1 vs 0)  |   .0346162    .007426     4.66   0.000     .0200614    .0491709
// ------------------------------------------------------------------------------

//	Conclusión: 
//	El efecto del programa, con Matching, sigue siendo significativo, pero disminuye. Esto indica que el efecto calculado anteriormente (con regresión) está sobreestimado, probablemente debido a las grandes diferencias entre los grupos. Además, el ATT es menor que el ATE, lo que refuerza la afirmación de que las comunas tratados ya tenían más propensión a aumentar su area de conservación. La variable popdensity también fué omitida, debido a la colinearidad entre pre_acres, income y popdensity.


*-------------------------------------------------------------------*
*							PREGUNTA 5								*
*-------------------------------------------------------------------*


//	Estimación del Average Treatment Effect (ATE) a traves de matching para el vecino más cercano (N Neighbor = 1), incorporando caliper como 0.5 desviaciones estándar 

// teffects nnmatch (post_acres $controles) (consprog), ate caliper(1) osample(unmatched)
// teffects nnmatch (post_acres $controles) (consprog) if unmatched != 1, ate caliper(1)
// drop unmatched

//	Estimación del Average Treatment Effect on Treated (ATT) a traves de matching para el vecino más cercano (N Neighbor = 1), incorporando caliper como 0.5 desviaciones estándar 

// teffects nnmatch (post_acres $controles) (consprog), atet caliper(0.5)


// Estimación de impacto (coefficient ß): 
	
// Conclusiónes: 
//	

*-------------------------------------------------------------------*
*							PREGUNTA 6								*
*-------------------------------------------------------------------*

// PASO 1: estimación prpoensity scores
probit consprog $controles, r

// ------------------------------------------------------------------------------
//              |               Robust
//     consprog | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//    pre_acres |  -46.59549   3.886711   -11.99   0.000    -54.21331   -38.97768
//       income |   .0004254   .0000483     8.80   0.000     .0003307    .0005202
//   popdensity |          0  (omitted)
//       _cons |   3.380072   .3359286    10.06   0.000     2.721664     4.03848
// ------------------------------------------------------------------------------
** todas las varaibles son significativas

predict pscore // En vez de pscore pudimos haber escrito cualquier cosa

// PASO 2: restringir al soporte común 

** Gráficamente
kdensity pscore if consprog == 0, addplot(kdensity pscore if consprog == 1) xtitle(Propensity Scores) legend(order(1 "Comunas No Tratadas" 2 "Comunas Tratadas"))

** Cotas:
sum pscore if consprog==0
// Comunas No Tratadas

//     Variable |        Obs        Mean    Std. dev.       Min        Max
// -------------+---------------------------------------------------------
//       pscore |        300    .2620113    .2156747   .0032378    .845939

sum pscore if consprog==1
// Comunas Tratadas

//     Variable |        Obs        Mean    Std. dev.       Min        Max
// -------------+---------------------------------------------------------
//       pscore |        200    .6127921    .2620551   .0288198   .9899962

**mayor minimo: 0.0288198
**menor maximo: 0.845939

** Creamos dummy para soporte común:
gen sop_comun=(pscore>=0.0288198 & pscore<=0.845939)

** Chequear representatividad 
sum sop_comun 
//     Variable |        Obs        Mean    Std. dev.       Min        Max
// -------------+---------------------------------------------------------
//    sop_comun |        500        .844    .3632187          0          1


// PASO 3: Estimación del ATE

teffects psmatch (post_acres) (consprog $controles, probit) if sop_comun==1, ate nneighbor(1)

// note: popdensity omitted because of collinearity.
// ------------------------------------------------------------------------------
// Treatment-effects estimation                   Number of obs      =        432
// Estimator      : propensity-score matching     Matches: requested =          1
// Outcome model  : matching                                     min =          1
// Treatment model: probit                                       max =          1
// ------------------------------------------------------------------------------
//              |              AI robust
//   post_acres | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
// ATE          |
//     consprog |
//    (1 vs 0)  |   .0436139   .0078417     5.56   0.000     .0282445    .0589834
// ------------------------------------------------------------------------------

// PASO 4: Estimación del ATT

teffects psmatch (post_acres) (consprog $controles, probit) if sop_comun==1, atet nneighbor(1)

// note: popdensity omitted because of collinearity.
// ------------------------------------------------------------------------------
// Treatment-effects estimation                   Number of obs      =        432
// Estimator      : propensity-score matching     Matches: requested =          1
// Outcome model  : matching                                     min =          1
// Treatment model: probit                                       max =          1
// ------------------------------------------------------------------------------
//              |              AI robust
//   post_acres | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
// ATE          |
//     consprog |
//    (1 vs 0)  |   .0543602   .0082044     6.63   0.000     .0382799    .0704404
// ------------------------------------------------------------------------------

// Otros comandos
// . ssc install psmatch2, replace
// psmatch2 consprog pre_acres income popdensity, ate out(post_acres) neighbor(1) caliper(0.5)
// psgraph
// pstest pre_acres income popdensity



