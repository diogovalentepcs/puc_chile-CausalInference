**********************************************
*       Tarea 4 EEPS - VI - Dif en Dif       *		
*           16 de noviembre de 2022          *
*            Inês Queirós Pereira            *
*            Diogo Valente Polonia           *
**********************************************

clear all

//directorio
cd "C:\Users\iqp20\OneDrive\Ambiente de Trabalho"

** -- Diferencias en Diferencias -- **

//base de datos
use "DB2.dta"
describe

* --- PREGUNTA 2 --- *

*Variable de participación individual: P
*Variable de tratamiento individual (año 1998): T98
*Variable de tratamiento a nivel hogar (año 1998): Trat
*Variable de interacción de timing con el tratamiento
gen TratPost=Trat*Post //Tratamiento (año 1998)

reg lnexpfd Trat Post TratPost

//Interpretacion: La participación en el programa en el ano de 1998 aumento en cerca de 3% el consumo de alimentos per capita de los hogares (Coef. TratPost = 0.0299295). Sin embargo como el valor p = 0.381 > 0.05, para un nivel de significancia de 5%, el resultado no es significativo. Asi, el programa no cumple con sus objetivos de aumentar el gasto per capita por hogar en Bangladesh porque su resultado no es significativo.

reg lnexpfd Trat Post TratPost egg agehead educhead

//Interpretacion: Controlando por las variables egg, agehead y educhead, se concluye que el resultado sigue siendo no significativo (p-value = 0.551) y que la participación en el programa en el ano de 1998 aumento en cerca de 2% (menor aumento) el consumo de alimentos per capita de los hogares (Coef. TratPost = 0.0193635).

* --- PREGUNTA 3 --- *

*Supuesto de identificación

preserve
keep if year==-1 | year==0 | year==1
collapse (mean) lnexpfd, by(year Trat)
xtset Trat year
twoway (tsline lnexpfd if Trat==0) || (tsline lnexpfd if Trat==1), legend(label(1 "Control") label(2 "Tratados"))
restore

//Interpretacion: Para que el método Dif-Dif sea válido, el grupo de control debe representar con exactitud el cambio en los resultados que habría experimentado el grupo de tratamiento. El resultado en el grupo de tratamiento se debe mover en paralelo con el resultado en el grupo de control, para que los resultados muestren tendencias iguales en ausencia del tratamiento. De este modo, se tiene que cumplir el supuesto de identificación: ambos grupos deben de seguir tendencias paralelas, es decir, no hay cambios en los no observables a lo largo del tiempo. Analizando el gráfico, se puede ver que antes de la aplicación del tratamiento, antes del año 1998, los dos grupos presentan líneas rectas paralelas, es decir tenían una tendencia de evolución paralela antes del tratamiento, por lo tanto se verifica el supuesto de identificación


** -- Variables Instrumentales -- **

//base de datos
use "DB1.dta", clear

* --- PREGUNTA 1 --- *
describe
sum trust_neighbors ln_export_area distsea

* --- PREGUNTA 2 --- *
global baseline_controls "age age2 male urban_dum i.education i.occupation i.religion i.living_conditions district_ethnic_frac frac_ethnicity_in_district"
global colonial_controls "malaria_ecology total_missions_area explorer_contact railway_contact cities_1400_dum i.v30 v33"

**Variable dependiente: trust_neighbors 
**Variable independiente: ln_export_area 

reg trust_neighbors ln_export_area $baseline_controls $colonial_controls

//Interpretacion: Cada esclavo negociado/km^2 reduce en 10.5% (Coefficient: -0.1050591) la confianza hacia los demas. Para un p-value de 0.000 este es un resultado significativo, para un nivel de significancia de 5%. Ademas, algumas variables controladas presentan un resultado no significativo (p-value > 0.05), por lo que se considera que no tienen impacto en el resultado obtenido. Para este caso la metodologia OLS puede no ser una buena metodologia para evaluar la causalidade porque puede existir un sesgo de endogeneidad. Si la variable independiente es una variable endógena, o sea, la variable independiente afecta la variable dependiente y la dependiente afecta la independiente, se dice que existe un sesgo de endogeneidad. De este modo, como la variable independiente está correlacionada con el error, el efecto de la variable independiente en la variable dependiente está sesgado. Como la exportacion de esclavos viola uno de los derechos básicos de la humanidad, esta afecta la confianza que las personas tienen por los demas ya que no les proporcionan unas condiciones de vida dignas. Sin embargo, la confianza o desconfianza entre los demas tambien podría estar influyendo en el comercio de esclavos, ya que con la desconfianza, la gente está más alerta y se protege de los posibles abusos/tráfico que podría sufrir, y además al alejar a la gente, podría perjudicar la creación de un negocio de comercio de esclavos. Así, que la confianza también puede estar influyendo en el comercio de esclavos y creando una endogeneidad que hace que la regresión OLS esté sesgada y no determine la causalidad.

* --- PREGUNTA 3 --- *

*Variable instrumental: distsea
reg ln_export_area distsea $baseline_controls $colonial_controls
corr ln_export_area distsea

//Interpretacion: Para un nivel de significancia de 5%, como el p-value es menor que el nivel de significancia, se rechaza la hipotesis nula, por lo tanto el instrumento es significativo. Ademas, se comproba que la covarianca entre estas dos variables es distinta de cero (-0.4291), por lo tanto se comproba el supuesto de relevancia, es decir, el instrumento es relevante.

* --- PREGUNTA 4 --- *

ivregress 2sls trust_neighbors $baseline_controls $colonial_controls (ln_export_area=distsea), first

//Interpretacion: Cada esclavo negociado/km^2 aumenta en 0.4% (Coefficient: 0.0041742) la confianza hacia los demas. Sin embargo este resultado no es significativo porque el p-value de 0.900 es mayor que el nivel de significancia de 5%.



