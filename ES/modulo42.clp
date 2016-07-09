;(div coso1 coso2) division entera de clips


;regla para buscar las 5 mejores recomendaciones encontradas por el SE
(defrule buscarMejorRecomendacion
  (Modulo42)
  ?f <- (NumPropuestas ?NP)
  (test (< ?NP 5));si no se han seleccionado ya 5 recomendaciones
  (Recomendacion (ID ?Id1) (RE ?RE1))
  (not (Propuesta ?Id1));la Recomendacion no ha sido ya escogida
  (not  (and (Recomendacion (ID ?Id2) (RE ?RE2)) (not (Propuesta ?Id2)) (test(> ?RE2 ?RE1)) ) ) ;no hay ninguna Recomendacion con mayor RE que ésta que no haya sido ya escogida
  =>
  (retract ?f)
  (assert (NumPropuestas (+ ?NP 1)));actualizamos el contador
  (assert (Propuesta ?Id1))
)

;regla para mostrar dichas 5 reglas
(defrule mostrarLas5Propuestas
  (declare (salience -1));para que no se ejecute hasta haber seleccionado el máximo número posible de acciones
  (Modulo42)
  (Propuesta ?Id)
  (Recomendacion (ID ?Id) (RE ?RE) (Texto ?Txt))
  =>
  (printout t "ID Propuesta: " ?Id " RE: " ?RE  crlf "Propuesta: " ?Txt crlf crlf crlf)
  (assert (SolicitarAccion))
)

;regla para pedirle al usuario qué propuesta acepta (si acepta alguna)
(defrule solicitarAccionARealizar
  (declare (salience -10));para que no se ejecute hasta haber mostrado todas las acciones seleccionadas
  (Modulo42)
  ?f <- (SolicitarAccion)
  =>
  (retract ?f)
  (printout t "Introduzca el ID de la accion que desea realizar entre las propuestas o -1 si no acepta ninguna" crlf)
  (bind ?Respuesta (read));tomamos la respuesta del usuario
  (assert (Aceptada ?Respuesta))
)

;regla para rechazar, si no es correcta, la respuesta que dé el usuario
(defrule rechazarAceptada
  (Modulo42)
  ?f <- (Aceptada ?Respuesta)
  ;si la respuesta no es -1 ni el ID de las acciones seleccionadas
  (and
    (test (<> ?Respuesta -1))
    (not (Propuesta ?Respuesta))
  )
  =>
  (retract ?f)
  (assert (SolicitarAccion));volvemos a pedirle al usuario respuesta
)

;regla para dar el control al módulo de manejo de acción correspondiente si el usuario a elegido alguna de las propuestas
(defrule aceptarAccion
  ?f <- (Modulo42)
  (Aceptada ?Respuesta)
  (Propuesta ?Respuesta)
  (Recomendacion (ID ?Respuesta) (Accion ?Accion))
  =>
  (retract ?f)
  (assert (Inicio ?Accion))
)

;regla para procesar qué hacer si el usuario no acepta ninguna opción
(defrule manejarRechazo
  (Modulo42)
  ?f <- (Aceptada -1);el usuario no ha aceptado ninguna acción
  =>
  (retract ?f)
  (printout t "Desea ver otras propuestas o volver al menu principal? (1 - propuestas 2 - menu)" crlf)
  (bind ?Respuesta (read))
  (assert (OpcElegida ?Respuesta))
)

;regla para rechazar la opción elegida por el usuario
(defrule rechazarOpcion
  (Modulo42)
  ?f <- (OpcElegida ~1&~2);si no ha elegido ni 1 ni 2
  =>
  (retract ?f)
  (assert (Aceptada -1))
)

;regla para salir del asistente de inversión al menú principal
(defrule salirDelAsistente
  ?h <- (Modulo42)
  ?f <- (OpcElegida 2)
  ?g <- (NumPropuestas ?)
  =>
  (assert	(NumPropuestas 0))
  (retract ?f ?h)
  (assert (Menu))
)

;regla para eliminar todas las recomendaciones que han sido rechazadas por el usuario si no acepta ninguna
(defrule limpiarParaMostrarOtrasPropuestas
  (OpcElegida 1)
  ?f <- (Propuesta ?Id)
  ?g <- (Recomendacion (ID ?Id))
  =>
  (retract ?f ?g)
)

;regla para mostrar nuevas propuestas, si las hay, después de que el usuario haya rechazado las 5 mostradas
(defrule mostrarNuevasPropuestas
  (declare (salience -1))
  ?f <- (OpcElegida 1)
  ?g <- (NumPropuestas ?)
  (exists (Recomendacion));hay más recomendaciones a mostrar
  =>
  (retract ?f ?g)
  (assert	(NumPropuestas 0))
)

;regla para salir del asistente si el usuario quiere que se le muestren otras 5 opciones y no hay más
(defrule noHayMasPropuestas
  (declare (salience -2))
  ?h <- (Modulo42)
  ?f <- (OpcElegida 1)
  ?g <- (NumPropuestas ?)
  =>
  (retract ?f ?g ?h)
  (assert	(NumPropuestas 0))
  (printout t "No hay mas propuestas, volvemos al menu principal." crlf)
  (assert (Menu))
)

;ACCIONES A REALIZAR UNA VEZ SE HA MANEJADO LA ACCIÓN ELEGIDA POR EL USUARIO

;continuar con el Módulo 4.2 una vez se ha completado la limpieza correspondiente
(defrule continuarModulo42
  (declare (salience -1));para que no se ejecute hasta haberse completado la limpieza
  ?f <- (Limpiar Compra|Venta|Intercambio)
  =>
  (retract ?f)
  (assert (Continua Modulo42))
)

;regla para eliminar los hechos que indican las recomendaciones seleccionadas
(defrule limpiarPropuestas
  (Continua Modulo42)
  ?f <- (Propuesta ?)
  =>
  (retract ?f)
)

;regla que elimina la Recomendación que el usuario a aceptado y que ha sido realiada
(defrule limpiarRecomendacion
  (Continua Modulo42)
  ?f <- (Aceptada ?Id)
  ?g <- (Recomendacion (ID ?Id))
  =>
  (retract ?f ?g)
)

;regla para volver al Módulo 1 par recalcular eventualmente valores peligrosos
(defrule volverAModulo1
  (declare (salience -1))
  ?f <- (Continua Modulo42)
  ?g <- (NumPropuestas ?)
  =>
  (retract ?f ?g)
  (assert	(NumPropuestas 0));reiniciamos el contador de propuestas
  (assert (Modulo1 42))
)
