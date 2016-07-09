;MODULO 4.2 GESTIONAR INTERCAMBIAR

;REGLAS PARA PEDIR AL USUARIO CUÁNTAS ACCIONES DESEA CAMBIAR DE VALOR

;función que realiza la división entera entre a y b
(deffunction divEntera (?a ?b)
  (return (div (/ ?a ?b) 1))
)

;regla para solicitar al usuario el número de acciones de la Empresa2 a cambiar por acciones de la Empresa1
(defrule solicitarAccionesAIntercambiar
  ?f <- (Inicio Intercambiar)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1) (Empresa2 ?E2))
  (Cartera ?E2 ?Acciones ?)
  =>
  (retract ?f)
  (printout t "Cuantas acciones de " ?E2 " desea cambiar por acciones de " ?E1 "? Dispone de: " ?Acciones " acciones. (Ha de ser un numero positivo)" crlf)
  (bind ?Respuesta (read))
  (assert (QuiereIntercambiar ?Respuesta))
)

;regla para rechazar la respuesta del usuario en caso de ser errónea
(defrule rechazarIntercambio
  ?f <- (QuiereIntercambiar ?Respuesta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1) (Empresa2 ?E2))
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec1))
  (DatosEmpresa (Nombre ?E2) (Precio ?Prec2))
  (Cartera ?E2 ?Acciones ?)
  (or
    (test (< ?Respuesta 0));ha indicado un número negativo de acciones
    (test (> ?Respuesta ?Acciones));ha indicado un número de acciones superior del que dispone
    (test (< (*  0.995 ?Respuesta ?Prec2) (* 1.005 ?Prec1))) ;las acciones a intercambiar no permiten obtener ni una acción de la otra empresa
  )
  =>
  (retract ?f)
  (assert (Inicio Intercambiar))
)

;regla para realizar el intercambio cuando no tenemos acciones de ese valor en la cartera
(defrule realizarIntercambio1
  ?f <- (QuiereIntercambiar ?Respuesta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1) (Empresa2 ?E2))
  ?g <- (Cartera ?E2 ?Acciones ?)
  ?h <- (Cartera DISPONIBLE ?D ?)
  (not (Cartera ?E1 ? ?));no tenemos acciones de ese valor en la cartera
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec1))
  (DatosEmpresa (Nombre ?E2) (Precio ?Prec2))
  (and
    (test (>= ?Respuesta 0)) ;el número de acciones indicado no es negativo
    (test (<= ?Respuesta ?Acciones)) ;disponemos de ese número de acciones
    (test (>= (* 0.995 ?Respuesta ?Prec2) (* 1.005 ?Prec1))) ;comprobar que podamos obtener al menos una acción con el intercambio
  )
  =>
  (retract ?f ?g ?h)

  ;disminuimos el número de acciones de la empresa intercambiada
  (bind ?accionesQueQuedan (- ?Acciones ?Respuesta))
  (if (> ?accionesQueQuedan 0) then (assert (Cartera ?E2 ?accionesQueQuedan (* ?accionesQueQuedan ?Prec2))))
  ;calculamos cuánto dinero nos proporcionan las acciones intercambiadas con la comisión
  (bind ?valorAccionesIntercambiadas (* ?Respuesta ?Prec2 0.995))
  ;calculamos cuántas acciones se obtienen con el intercambio
  (bind ?accionesObtenidas (divEntera ?valorAccionesIntercambiadas (* ?Prec1 1.005)))
  ;introducimos en la cartera las acciones obtenidas con el intercambio
  (assert (Cartera ?E1 ?accionesObtenidas (* ?accionesObtenidas ?Prec1)))
  ;introducimos el dinero sobrante de la operación en la cartera
  (bind ?nuevoCash (+ ?D ?valorAccionesIntercambiadas (* -1.005 ?accionesObtenidas ?Prec1)))
  (assert (Cartera DISPONIBLE ?nuevoCash ?nuevoCash))

  (assert (Limpiar Intercambio))
)

;regla para realizar el intercambio cuando tenemos acciones de ese valor en la cartera
(defrule realizarIntercambio2
  ?f <- (QuiereIntercambiar ?Respuesta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1) (Empresa2 ?E2))
  ?g <- (Cartera ?E2 ?Acciones2 ?)
  ?h <- (Cartera DISPONIBLE ?D ?)
  ?i <- (Cartera ?E1 ?Acciones1 ?) ;ya tenemos acciones de este valor en la cartera
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec1))
  (DatosEmpresa (Nombre ?E2) (Precio ?Prec2))
  (and
    (test (>= ?Respuesta 0))
    (test (<= ?Respuesta ?Acciones2))
    (test (>= (* 0.995 ?Respuesta ?Prec2) (* 1.005 ?Prec2)))
  )
  =>
  (retract ?f ?g ?h ?i)

  (bind ?accionesQueQuedan (- ?Acciones2 ?Respuesta))
  (if (> ?accionesQueQuedan 0) then (assert (Cartera ?E2 ?accionesQueQuedan (* ?accionesQueQuedan ?Prec2))))

  (bind ?valorAccionesIntercambiadas (* ?Respuesta ?Prec2 0.995))
  ;aumentamos el número de acciones de Empresa1 de las que disponemos
  (bind ?accionesObtenidas (divEntera ?valorAccionesIntercambiadas (* ?Prec1 1.005)))
  (assert (Cartera ?E1 (+ ?accionesObtenidas ?Acciones1) (* (+ ?accionesObtenidas ?Acciones1) ?Prec1)))

  (bind ?nuevoCash (+ ?D ?valorAccionesIntercambiadas (* -1.005 ?accionesObtenidas ?Prec1)))
  (assert (Cartera DISPONIBLE ?nuevoCash ?nuevoCash))

  (assert (Limpiar Intercambio))
)

;Las siguientes reglas se emplean para eliminar aquella información de la BC del SE
;que deja de tener sentido al desaparecer un valor de la cartera del cliente
(defrule limpiezaTrasIntercambio1
  (Limpiar Intercambio)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa2 ?E2))
  (not (Cartera ?E2 ? ?))
  ?f <- (Recomendacion (Accion Vender) (Empresa1 ?E2));si no hay acciones del valor no se pueden vender
  =>
  (retract ?f)
)

(defrule limpiezaTrasIntercambio2
  (Limpiar Intercambio)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa2 ?E2))
  (not (Cartera ?E2 ? ?))
  ?f <- (Recomendacion (ID ?Id2 & ~?Id) (Accion Intercambiar) (Empresa2 ?E2));si no hay acciones del valor no se pueden intercambiar
  =>
  (retract ?f)
)

(defrule limpiezaTrasIntercambio3
  (Limpiar Intercambio)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa2 ?E2))
  (not (Cartera ?E2 ? ?))
  ?f <- (Peligroso ?E2 ?);si no hay acciones de valor deja de ser peligroso
  =>
  (retract ?f)
)
