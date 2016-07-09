;MÓDULO 4.1
;template para almacenar los datos de una recomendación realizada
(deftemplate Recomendacion
  (field ID (type NUMBER))
  (field Accion (type SYMBOL) (allowed-symbols Vender Comprar Intercambiar))
  (field RE (type NUMBER))
  (field Empresa1)
  (field Empresa2 (default NULL))
  (field Texto)
)

;Si una empresa es peligrosa, ha bajado el último mes y ha bajado más de un 3% con
;respecto a su sector en el último mes, proponer vender las acciones de la empresa
(defrule proponerVenderPeligrosos
  (Modulo41)
  ?f <- (Ids ?Id)
  (Peligroso ?Nom ?Exp);es peligrosa
  (DatosEmpresa (Nombre ?Nom) (RPD ?RPD) (Sector ?Sec) (VarMes ?VarMes))
  (DatosSector (Nombre ?Sec) (VarMes ?VarMesSec))
  (not (Recomendacion (Accion Vender) (Empresa1 ?Nom))) ; no hemos hecho ya esta propuesta
  (test (< ?VarMes 0));ha bajado en el último mes
  (test (< (- ?VarMes ?VarMesSec) -3));ha bajado respecto a su sector más de un 3%
  =>
  (bind ?RE (- 20 (* 100 ?RPD)))
  (assert (Recomendacion (ID ?Id) (Accion Vender) (RE ?RE) (Empresa1 ?Nom)
    (Texto (str-cat "Te recomiendo vender las acciones de " ?Nom ". Explicacion: La empresa es peligrosa porque " ?Exp ", ademas esta entrando en tendencia bajista con respecto
    a su sector. Segun mi estimacion existe una probabilidad no despreciable de que pueda caer al cabo de un ano un 20%, aunque
    produzca un " (* 100 ?RPD) " por dividendos perderiamos el " ?RE "%." )))
  )
  (retract ?f)
  (assert (Ids (+ ?Id 1)))
)

;Si una empresa está infravalorada y el usuario tiene dinero para invertir proponer
;invertir el dinero en la acciones de la empresa.
(defrule proponerInvertirInfravalorados
  (Modulo41)
  ?f <- (Ids ?Id)
  (Cartera DISPONIBLE ?Cash ?)
  (Infravalorado ?Nom ?Exp);valor Infravalorado
  (DatosEmpresa (Nombre ?Nom) (Precio ?Prec) (PER ?PER) (RPD ?RPD))
  (DatosSector (Nombre Ibex) (PER ?PERMedio))
  (not (Recomendacion (Accion Comprar) (Empresa1 ?Nom)));no hemos hecho ya esta recomendacion
  (test (>= ?Cash (* 1.005 ?Prec))) ;el usuario tiene dinero al menos para una acción sumando la comisión
  (test (<> ?PER 0));para poder hacer la división
  =>
  (bind ?RE (+ (/ (* 20 (- ?PERMedio ?PER)) ?PER) (* 100 ?RPD)))
  (assert (Recomendacion (ID ?Id) (Accion Comprar) (RE ?RE) (Empresa1 ?Nom)
    (Texto (str-cat "Te propongo invertir en " ?Nom ". Explicacion: Esta empresa esta infravalorada porque " ?Exp ", y seguramente el PER tienda al PER medio en 5 anos, con
    lo que se deberia revalorizar un " (/ (* 20 (- ?PERMedio ?PER)) ?PER) "anual a lo que habria que sumar el " (* 100 ?RPD)
    "% de beneficios por dividendos.")))
  )
  (retract ?f)
  (assert (Ids (+ ?Id 1)))
)

; Si una empresa de mi cartera está sobrevalorada y el rendimiento por año es < que 5 + precio del dinero
; proponer vender las acciones de la empresa
(defrule proponerVenderSobrevalorados
  (Modulo41)
  ?f <- (Ids ?Id)
  (Cartera ?Nom ? ?);valor de mi cartera
  (Sobrevalorado ?Nom ?Exp);sobrevalorado
  (DatosEmpresa (Nombre ?Nom) (Sector ?Sec) (PER ?PER) (RPD ?RPD) (Var12mes ?VarAno))
  (DatosSector (Nombre ?Sec) (PER ?PERSector))
  (PrecioDinero ?PrecDinero)
  (not (Recomendacion (Accion Vender) (Empresa1 ?Nom)));no hemos hecho ya esta recomendacion
  (test (< (+ (* 100 ?RPD) ?VarAno) (+ 5 ?PrecDinero)));vemos si el RA es menor que 5 + el precio del dinero
  (test (<> ?PER 0));para poder hacer la división
  =>
  (bind ?RE (+ (* -100 ?RPD) (/ (* 20 (- ?PER ?PERSector)) ?PER)))
  (assert (Recomendacion (ID ?Id) (Accion Vender) (RE ?RE) (Empresa1 ?Nom)
    (Texto (str-cat "Te recomiendo vender las acciones de " ?Nom ". Explicacion: Esta empresa esta sobrevalorada porque " ?Exp ", es mejor amortizar lo invertido, ya que seguramente
    el PER tan alto debera bajar al PER medio del sector en unos 5 anos, con lo que se deberia devaluar un " (/ (* 20 (- ?PER ?PERSector)) ?PER)
    " anual, asi aunque se pierda el " (* 100 ?RPD) "% de beneficios por dividendos saldria rentable." )))
  )
  (retract ?f)
  (assert (Ids (+ ?Id 1)))
)

; Si una empresa (E1) no está sobrevalorada y su RPD es mayor que RA + RPD + 1 de una empresa de mi cartera
; (donde RA es el rendimiento por año esperado) E2 que no está infravalorada, proponer cambiar las acciones
; de una empresa por las de la otra
(defrule proponerIntercambiarAcciones
  (Modulo41)
  ?f <- (Ids ?Id)
  (Cartera ?Nom2 ? ?ValorActual)
  (DatosEmpresa (Nombre ?Nom1) (RPD ?RPD1) (Precio ?Prec))
  (DatosEmpresa (Nombre ?Nom2 & ~?Nom1) (RPD ?RPD2) (Var12mes ?VarAno));datos de una empresa que no sea la misma
  (not (Infravalorado ?Nom2 ?));la empresa de mi cartera no está infravalorada
  (not (Sobrevalorado ?Nom1 ?));la otra empresa no está sobrevalorada
  (test (> (* 100 ?RPD1) (+ (+ (* 100 ?RPD2) ?VarAno) (* 100 ?RPD2) 1)));vemos que el RPD de la otra empresa es mejor que RPD + rendimiento_anual de la otra más 1
  (test (>= (- ?ValorActual (/ ?ValorActual 200)) (+ ?Prec (/ ?Prec 200)) )) ;que al menos tengamos dinero para una acción contando con las comisiones
  (not (Recomendacion (Accion Intercambiar) (Empresa1 ?Nom1) (Empresa2 ?Nom2)));no hemos hecho ya esta recomendacion
  =>
  (bind ?RE (- (* 100 ?RPD1) (+ (+ (* 100 ?RPD2) ?VarAno) (* 100 ?RPD2) 1)))
  (assert (Recomendacion (ID ?Id) (Accion Intercambiar) (RE ?RE) (Empresa1 ?Nom1) (Empresa2 ?Nom2)
    (Texto (str-cat "Te recomiendo cambiar tus acciones en " ?Nom2 " por acciones en " ?Nom1 ". Explicacion: " ?Nom1 " debe tener una revalorizacion acorde con la evolucion de la bolsa. Por dividendos se espera un "
    (* 100 ?RPD1) "% que es más de lo que te está dando " ?Nom2 ", por eso te propongo cambiar los valores por los de esta otra
    (rendimiento por ano obtenido de " (+ ?VarAno (* 200 ?RPD2)) "de beneficios). Aunque se pague el 1% del coste de cambio te saldria
    rentable.")))
  )
  (retract ?f)
  (assert (Ids (+ ?Id 1)))
)

;regla para pasar al Módulo 4.2
(defrule pasarAModulo42
  (declare (salience -1))
  ?f <- (Modulo41)
  =>
  (retract ?f)
  (assert (Modulo42))
)
