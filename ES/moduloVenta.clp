;MODULO 4.2 GESTIONAR VENDER

;REGLAS PARA PEDIR AL USUARIO CUÁNTAS ACCIONES DESEA VENDER

;regla para solicitar al usuario el número de acciones a vender
(defrule solicitarAccionesAVender
  ?f <- (Inicio Vender)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  (Cartera ?E1 ?Acciones ?)
  =>
  (retract ?f)
  (printout t "Cuantas acciones de " ?E1 " desea vender? Dispone de: " ?Acciones " acciones. (Ha de ser un numero positivo)"  crlf)
  (bind ?Respuesta (read))
  (assert (QuiereVender ?Respuesta))
)

;regla para rechazar la respuesta del usuario con las acciones a vender y volver a solicitarle ese número
(defrule rechazarVenta
  ?f <- (QuiereVender ?Respuesta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  (Cartera ?E1 ?Acciones ?)
  ;si el número de acciones indicado es negativo o supera el número de acciones disponible
  (or
    (test (< ?Respuesta 0))
    (test (> ?Respuesta ?Acciones))
  )
  =>
  (retract ?f)
  (assert (Inicio Vender))
)

;regla para realizar la venta de las acciones
(defrule realizarVenta
  ?f <- (QuiereVender ?Respuesta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  ?g <- (Cartera ?E1 ?Acciones ?)
  ?h <- (Cartera DISPONIBLE ?D ?)
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec)) ;tomamos el precio de las acciones de esa empresa
  ;si el número no es negativo y hay suficientes acciones en la cartera
  (and
    (test (>= ?Respuesta 0))
    (test (<= ?Respuesta ?Acciones))
  )
  =>
  (retract ?f ?g ?h)
  (bind ?accionesQueQuedan (- ?Acciones ?Respuesta)) ;reducimos el número de acciones disponibles del valor en la cartera tras la Venta
  ;si no queda ninguna entonces desaparece el valor de la cartera
  (if (> ?accionesQueQuedan 0) then (assert (Cartera ?E1 ?accionesQueQuedan (* ?accionesQueQuedan ?Prec))))
  (bind ?nuevoCash (+ ?D (* 0.995 ?Respuesta ?Prec)));aumentamos el dinero tras la compra quitando la comisión
  (assert (Cartera DISPONIBLE ?nuevoCash ?nuevoCash))
  (assert (Limpiar Venta))
)

;Las siguientes reglas se emplean para eliminar aquella información de la BC del SE
;que deja de tener sentido al desaparecer un valor de la cartera del cliente
(defrule limpiezaTrasVenta1
  (Limpiar Venta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  (not (Cartera ?E1 ? ?))
  ?f <- (Recomendacion (ID ?Id2 & ~?Id) (Accion Vender) (Empresa1 ?E1));si no hay acciones del valor no se pueden vender
  =>
  (retract ?f)
)

(defrule limpiezaTrasVenta2
  (Limpiar Venta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  (not (Cartera ?E1 ? ?))
  ?f <- (Recomendacion (Accion Intercambiar) (Empresa2 ?E1));si no hay acciones del valor no se pueden intercambiar
  =>
  (retract ?f)
)

(defrule limpiezaTrasVenta3
  (Limpiar Venta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  (not (Cartera ?E1 ? ?))
  ?f <- (Peligroso ?E1 ?);si no hay acciones de valor deja de ser peligroso
  =>
  (retract ?f)
)
