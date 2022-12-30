* 								TAREA 3 EEPS
*******************************************************************************************

cd "C:\Users\monts\OneDrive - uc.cl\Universidad\0. Minor Políticas Públicas\1.Economía y evaluación de las políticas sociales\Tareas"
ssc install rd 
ssc install binscatter
net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
net install lpdensity, from ("https://sites.google.com/site/nppackages/lpdensity/stata") replace


use rdd.dta, clear
describe

* PREGUNTA 1b:

*Variable de asignación:
hist poverty_rating, frequency xline(215)
rddensity poverty_rating , c(215) plot graph_opt(graphregion(color(white)))
help rddensity 

*generamos la variable de tratamiento
gen treat=(poverty_rating>215)

*********************
* PREGUNTA 2b:

*INDIVIDUOS SON SIMILARES EN EL CORTE: 
*las características que no se debiesen ver afectadas por el tratamiento, tienen que distribuirse homogeneamente alrededor del punto de corte

*Para homogeneidad alrededor del corte: 
global observables age gender esol sped  black

*Con binscatter
foreach var of global observables{
qui: binscatter `var' poverty_rating ,  nquantiles(50) rd(215) saving(g`var', replace)
}
graph combine gage.gph ggender.gph gesol.gph gsped.gph gblack.gph 
// Se ve en los graficos que hay variables que no son continuas en el corte esto es un problema

//Diferencias significativas (para analizar si las difrencias encontradas son significativas)
foreach var of global observables{
di "Esta es la variable `var'"
ttest `var', by(treat)
}

********************************************
*PREGUNTA 3: ANCHO DE BANDA 

* age 
ttest age if poverty_rating<220 & poverty_rating>210, by(treat)

* gender
ttest gender if poverty_rating<220 & poverty_rating>210, by(treat)

* esol 
ttest esol if poverty_rating<220 & poverty_rating>210, by(treat)

* sped
ttest sped if poverty_rating<220 & poverty_rating>210, by(treat)

* black
ttest black if poverty_rating<220 & poverty_rating>210, by(treat)

********************************************
*PREGUNTA 4: Causalidad 

rdrobust math_score poverty_rating, c(215)
rdplot math_score poverty_rating, c(215)

********************************************
*PREGUNTA 5: BONUS

set seed 206652284
gen science_score = rnormal(222, 12)

*Evaluamos impacto:
rdrobust science_score poverty_rating, c(215)
rdplot science_score poverty_rating, c(215)



** Nos equivocamos y definimos el umbral como >215, perdon :()
