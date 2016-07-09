;MODULO 4.2 GESTIONAR COMPRAR

;REGLAS PARA PEDIR AL USUARIO CUÁNTAS ACCIONES DESEA COMPRAR DE UN VALOR

;regla para solicitar al usuario el número de acciones que desea comprar
(defrule solicitarAccionesAComprar
  ?f <- (Inicio Comprar)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  (Cartera DISPONIBLE ?Cash ?)
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec))
  =>
  (retract ?f)
  (printout t "Cuantas acciones de " ?E1 " desea comprar? Dispone de: " ?Cash " euros. La accion cuesta " ?Prec " euros. (Ha de ser un numero positivo)"crlf)
  (bind ?Respuesta (read))
  (assert (QuiereComprar ?Respuesta))
)

;regla para rechazar la respuesta del usuario con las acciones a comprar si no es correcta
(defrule rechazarCompra
  ?f <- (QuiereComprar ?Respuesta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec))
  (Cartera DISPONIBLE ?Cash ?)
  (or
    (test (< ?Respuesta 0)) ;si el número de acciones indicado es negativo
    (test (< ?Cash (* 1.005 ?Respuesta ?Prec))) ;si no hay suficiente dinero como para pagar esa cantidad de acciones junto la comisión
  )
  =>
  (retract ?f)
  (assert (Inicio Comprar))
)

;regla para realizar la compra cuando no tenemos acciones de esa empresa
(defrule realizarCompra1
  ?f <- (QuiereComprar ?Respuesta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  ?g <- (Cartera DISPONIBLE ?D ?)
  (not (Cartera ?E1 ? ?)) ;no tenemos acciones de ese valor
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec))
  (and
    (test (>= ?Respuesta 0)) ;el número indicado es positivo
    (test (>= ?D (* 1.005 ?Respuesta ?Prec))) ;dispone de sufiente dinero para comprar ese número de acciones contando la comisión
  )
  =>
  (retract ?f ?g)
  (bind ?cashTrasCompra (- ?D (* 1.005 ?Respuesta ?Prec))) ;disminuimos el dinero disponible por el usuario
  (assert (Cartera ?E1 ?Respuesta (* ?Respuesta ?Prec)))
  (assert (Cartera DISPONIBLE ?cashTrasCompra ?cashTrasCompra))
  (assert (Limpiar Compra))
)

;regla para realizar la compra cuando ya tenemos acciones de esa empresa
(defrule realizarCompra2
  ?f <- (QuiereComprar ?Respuesta)
  (Aceptada ?Id)
  (Recomendacion (ID ?Id) (Empresa1 ?E1))
  ?g <- (Cartera DISPONIBLE ?D ?)
  ?h <- (Cartera ?E1 ?accionesActuales ?) ;ya tenemos acciones de este valor
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec))
  (and
    (test (>= ?Respuesta 0))
    (test (>= ?D (* 1.005 ?Respuesta ?Prec)))
  )
  =>
  (retract ?f ?g ?h)
  (bind ?cashTrasCompra (- ?D (* 1.005 ?Respuesta ?Prec)))
  (bind ?accionesTrasCompra (+ ?accionesActuales ?Respuesta)) ;aumentamos las acciones de este valor en la cartera
  (assert (Cartera ?E1 ?accionesTrasCompra (* ?accionesTrasCompra ?Prec)))
  (assert (Cartera DISPONIBLE ?cashTrasCompra ?cashTrasCompra))
  (assert (Limpiar Compra))
)

;Regla para eliminar aquella información de la BC del SE que deja de tener sentido al disminuir el dinero disponible del cliente
(defrule limpiezaTrasCompra
  (Limpiar Compra)
  (Aceptada ?Id)
  (Cartera DISPONIBLE ?D ?)

  ?f <- (Recomendacion (ID ?Id2 & ~?Id) (Accion Comprar) (Empresa1 ?E1))
  (DatosEmpresa (Nombre ?E1) (Precio ?Prec))
  (test (< ?D (* 1.005 ?Prec)));tras la compra el dinero disponible no permite comprar una accion
  =>
  (retract ?f)
)
