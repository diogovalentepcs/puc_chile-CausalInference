***           TAREA 1: RCT           ***
*     Diogo Polonia & Inês Pereira     *
*             31/08/2022               *             

clear all

//Abra la base de datos "Tarea1.dta" directamente desde el do file
cd "C:\Users\iqp20\OneDrive\Ambiente de Trabalho"
use Tarea1.dta

//Antes de comenzar, observe la base de datos
describe

//Determine cuales son las variables que identifican los outcomes de interes del programa y la pertenencia del individuo al grupo tratamiento o de control
**Outcomes: z_irt_total_el & tooktest_el 

**Grupo de tratamiento: treatment 

//2.a) Indique si existen diferencias en cada una de las variables para los grupos de tratamiento y control
	local variables mothereducationbl zirttotalbl homeworkbl classsize schoolfemale attendancebl classprobsummi
	foreach variable of local variables{ 
	di "Esta es la variable `variable'" 
	ttest `variable', by(treatment)
	} 
	
*nivel de significancia: 5%
	
**mothereducationbl: no rechaza H0 (Pr(|T| > |t|) = 0.1294  > 0.05)
**zirttotalbl: rechaza H0 (Pr(|T| > |t|) = 0.0007 < 0.05)
**homeworkbl: no rechaza H0 (Pr(|T| > |t|) = 0.1497 > 0.05)
**classsize: no rechaza H0 (Pr(|T| > |t|) = 0.4827 > 0.05)
**schoolfemale: no rechaza H0 (Pr(|T| > |t|) = 0.1374 > 0.05)
**attendancebl: rechaza H0 (Pr(|T| > |t|) = 0.0011 < 0.05)
**classprobsummi: rechaza H0 (Pr(|T| > |t|) = 0.0000 < 0.05)

***Conclusión: En el caso de las variables que rechazan la hipótesis nula (valor p < alfa), hay pruebas estadísticamente significativas de que la media de estas variables es diferente entre los grupos, por lo que no se pueden comparar los grupos de tratamiento y control. Por lo tanto, hay que controlar estas variables: zirttotalbl, attendancebl, classprobsummi 

//3) Determine el efecto de la participacion del programa
**Outcome: Elearn Classrooms Standardized Combined Math and Science Test Score (Project)
	reg z_irt_total_el treatment
	**Coefficient: 15.31%
	**Para un nivel de significancia de 5%, como p-value = 0.001 es menor que 0.05, el resultado es estadísticamente significativo. Así, la participación en el programa Elearn Classrooms aumenta las puntuaciones de los alumnos en los exámenes de matemáticas y ciencias en 15.31%
	reg z_irt_total_el treatment zirttotalbl attendancebl classprobsummi
	**Coefficient: 27.3%
	**Controlando por las variables zirttotalbl, attendancebl y classprobsummi, se concluye que el resultado sigue siendo significativo (p-value = 0.000) y que la participación en el programa Elearn Classrooms aumenta las puntuaciones de los alumnos en los exámenes de matemáticas y ciencias en 27.3%
	
**Outcome: Elearn Classrooms -- Took Follow-up Exam
	reg tooktest_el  treatment
	**Coefficient:4.68%
	**Para un nivel de significancia de 5%, como p-value = 0.000 es menor que 0.05, el resultado es estadísticamente significativo. Así, la participación en el programa Elearn Classrooms aumenta la probabilidad rendir el examen de continuaidad del gobierno en 4,68%
	reg tooktest_el  treatment zirttotalbl attendancebl classprobsummi
	**Coefficient: 4.8%
	**Controlando por las variables zirttotalbl, attendancebl y classprobsummi, se concluye que el resultado sigue siendo significativo (p-value = 0.000) y que la participación en el programa Elearn Classrooms aumenta la probabilidad rendir el examen de continuaidad del gobierno en 4.8%. Sin embargo, las variables zirttotalbl y classprobsummi presentan un resultado no significativo (p-value > 0.05), por lo que se considera que no tienen impacto en el resultado obtenido.
	
//BONUS: Piense si existen otras variables en la bbdd que podrıan estar sesgando el beta estimado
	describe
	ttest _techcom_bl , by(treatment) 
	**Pr(|T| > |t|) = 0.0232 < 0.05, como se rechaza la hipótesis nula, esta variable apresenta diferencias significativas entre el grupo de tratamiento y de control, por lo que puede estar influyendo en los resultados, ya que la propiedad del ordenador influye en el uso del programa
	
	
	

