

//		Problem Set 1 : Experimento Aleatorio		//
//				Diogo Valente Polónia				//
//					  03/11/2022					//


clear all

// Directorio
cd "/Users/diogovalentepolonia/Projects/PoliticasAmbientales/P1"
	
// Base de Datos
use "earthfriends.dta"
describe


***************** Pregunta 1 ********************

//	Verificacion si existen diferencias en cada una de las variables observables (pre_pollution, age y employees) para los grupos de tratamiento y control a traves del t-test

local variables pre_pollution age employees
foreach variable of local variables { 
	di "Analisis de la variable `variable'" 
	ttest `variable', by(assignment)
} 

//	Analisis con nivel de significancia: 5% (alfa)
//	pre_pollution:	no rechaza H0 (Pr(|T| > |t|) = 0.1765 > 0.05)
//	age: 			no rechaza H0 (Pr(|T| > |t|) = 0.1765 > 0.05)
//	employees: 		no rechaza H0 (Pr(|T| > |t|) = 0.2885 > 0.05)

// Conclusión: Como no hay variables que rechazan la hipótesis nula (valor p < alfa), no hay pruebas estadísticamente significativas de que la media de estas variables sea diferente entre los grupos de control (plantas status quo) y tratamiento (plantas con nuevos protocolos), por lo que no se puede concluir que la assignación de tratamiento no fué aleatoria. Los valores p son signitivativos a 5%, 10% y 15%, lo que permite grande confianza estadistica. 


***************** Pregunta 2 ********************

//	t-test solo entre grupos de protocolo = 1 y protocolos = 2

local variables pre_pollution age employees
foreach variable of local variables{ 
	di "Analisis de la variable `variable'"  
	ttest `variable' if protocol != 0 , by(protocol)
} 

//	Analisis con nivel de significancia: 5% (alfa)	
//	pre_pollution: 	rechaza H0 (Pr(|T| > |t|) = 0.0386 < 0.05)
//	age: 			rechaza H0 (Pr(|T| > |t|) = 0.0386 < 0.05)
//	employees: 		no rechaza H0 (Pr(|T| > |t|) = 0.1322 > 0.05)

//	Conclusión: En el caso de las variables que rechazan la hipótesis nula, en que el valor p < alfa (pre_pollution y age), hay pruebas estadísticamente significativas de que la media de estas variables es diferente entre lo grupo con implementación a nível de planta y lo grupo con standard, por lo que no se pueden comparar los grupos sin controlar por estas variables. Por lo tanto, hay evidencia estadistica de un sesgo de selecion en la asignacion del tipo de protocolo.

***************** Pregunta 3 ********************

//	Y (outcome):	post_pollution
//	T (treatment):	assignment

// Estimación de los valores esperados con intervalod de convianza al 95%

ci means post_pollution, level(95)					// E(Y) 	= 	4383.195 ± 707.498
ci means post_pollution if assignment==1, level(95)	// E(Y|T=1) = 	3813.044 ± 779.204
ci means post_pollution if assignment==0, level(95)	// E(Y|T=0) = 	5523.499 ± 1408.276

//	Conclusiónes:
//	1. Se detectan diferencias entre los niveles de polucion entre los grupos de tratamiento y control, con una diminuición de 5523.559 - 3813.044 = 1710.455 del nível de polucion. O sea, se detecta un impacto del tratamiento: Impacto = E(Y|T=1) - E(Y|T=0) = -1710.455
//	2. Este impacto es significativo porque lo valor esperado E(Y|T=1) no está contenido en el intervalo de confianza de E(Y|T=0), y vice-versa. Sin embargo, como los intervalos de confianza se intersectán, la significancia estadistica puede no ser muy elevada
//	3. Los intervalos de confianza aumentan, es dicir E(Y) < E(Y|T=1) < E(Y|T=0), reflectindo la disminuición del tamaño mostral de cada uno de los grupos


***************** Pregunta 4 ********************

//	Estimación del impacto causal a traves de una regresión lineal

reg post_pollution assignment

//       Source |       SS           df       MS      Number of obs   =        60
// -------------+----------------------------------   F(1, 58)        =      5.61
//        Model |  39008779.6         1  39008779.6   Prob > F        =    0.0212
//     Residual |   403541345        58  6957609.39   R-squared       =    0.0881
// -------------+----------------------------------   Adj R-squared   =    0.0724
//        Total |   442550124        59  7500849.56   Root MSE        =    2637.7
// 
// ------------------------------------------------------------------------------
// post_pollu~n | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//   assignment |  -1710.456   722.3716    -2.37   0.021    -3156.439   -264.4718
//        _cons |   5523.499   589.8139     9.36   0.000     4342.858     6704.14
// ------------------------------------------------------------------------------

// Estimación de impacto (coefficient ß): -1710.456 
	
// Conclusión: El coeficiente de la variable de "assigment" de la regresion, para un nivel de significancia de 5%, es estadísticamente significativo, ya que el valor p (2.1%) es menor que el nivel de significancia (5%). Con esta regresion se podría concluir, entonces, que la implementación de nuevos protocolos de Sistemas de Manejo Ambiental (SMA) disminuye los niveles de polucion en 1710.456 valores. Esta conclusión es válida porque no se identificaran diferencias significativas entre los grupos y no hay evidencia de que los grupos no fueran aleatorios.


***************** Pregunta 5 ********************

//	Estimación del impacto causal a traves de una regresión lineal controlando por las variables age y employment

reg post_pollution assignment age employees

//       Source |       SS           df       MS      Number of obs   =        60
// -------------+----------------------------------   F(3, 56)        =      2.57
//        Model |  53534026.7         3  17844675.6   Prob > F        =    0.0634
//     Residual |   389016097        56  6946716.03   R-squared       =    0.1210
// -------------+----------------------------------   Adj R-squared   =    0.0739
//        Total |   442550124        59  7500849.56   Root MSE        =    2635.7
// 
// ------------------------------------------------------------------------------
// post_pollu~n | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//   assignment |  -1894.012   739.8779    -2.56   0.013    -3376.166   -411.8585
//          age |   141.8294   98.08312     1.45   0.154    -54.65471    338.3135
//    employees |  -.1963911   4.959705    -0.04   0.969    -10.13188    9.739093
//        _cons |   4827.919   1108.012     4.36   0.000     2608.304    7047.535
// ------------------------------------------------------------------------------

// Estimación de impacto (coefficient ß): -1894.012
	
// Conclusiónes: 
//	1. El control de la regresión por las variables age y employees (edad de la planta y número de empleados) permite aumentar la significancia de la estimación: el valor p disminui de 2.1% para 1.3% y el error de la estimación (_cons) disminui de 5523.499, E(Y|T=0),para 4827.919;
//	2. Se concluye con mayor grado de significancia que la implementación de los nuevos protocolos de Sistemas de Manejo Ambiental (SMA) disminuye los niveles de polucion en 1894.012 valores;
//	3. Los coeficientes de las variables age y employees no presentan un valor significativo pues su valor p es mucho mayor que 5% (15% y 97%, respectivamente), por lo que no hay evidencia que estas variables contribuan significativement para los valores de poluicion de las plantas, pero como su introducción disminuye el error, se puede concluir que estas variables tienen una relación con el error;
//	4. Así, lo resultado no es sustancialmente distinto de lo anterior pero es más significativo.
