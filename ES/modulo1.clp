;MÓDULO 1

;Si un valor es inestable y está perdiendo de forma continua durante los últimos 3 días es peligroso.
(defrule deducirPeligrosos1
  (Modulo1 ?) ;hemos pasado al Módulo1
  (Cartera ?Nom ? ?); es un valor de la cartera
  (Inestable ?Nom ?Exp); inestable
  (DatosEmpresa (Nombre ?Nom) (Bajando3 true)); lleva bajando 3 días
  (not (Peligroso ?Nom ?))
  =>
  (assert (Peligroso ?Nom (str-cat "lleva 3 dias bajando y es inestable porque " ?Exp)))
)

;Si un valor está perdiendo durante los últimos 5 días y la variación en esos 5 días
;con respecto a la variación del sector es > que un -5%, es peligroso.
(defrule deducirPeligrosos2
  (Modulo1 ?) ;hemos pasado al Módulo 1
  (Cartera ?Nom ? ?) ;es un valor de la cartera
  (DatosEmpresa (Nombre ?Nom) (Bajando5 true) (VRS5 false)) ;lleva bajando 5 días y la variación con respecto al sector es como se indica
  (not (Peligroso ?Nom ?))
  =>
  (assert (Peligroso ?Nom "esta perdiendo durante los ultimos 5 dias y la variacion en esos dias respecto a la del sector es mayor que un -5%"))
)

;regla para pasar al Módulo2 o al 4.1 según corresponda
(defrule pasarAModulo2o41
  (declare (salience -1)) ;última regla del módulo
  ?f <- (Modulo1 ?ModuloInvocador)
  =>
  (retract ?f)
  (if (= ?ModuloInvocador 0) then ;si me ha invocado el Módulo0 paso al dos
    (assert (Modulo2))
  else ;si me ha invocado el 4.2 paso al 4.1
    (assert (Modulo41))
  )
)
