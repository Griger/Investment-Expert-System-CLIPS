;fichero con el menu de inicio del programa

;regla para mostrar el menú
(defrule mostrarMenu
  ?f <- (Menu)
  =>
  (retract ?f)
  (printout t "Elija entre las siguientes opciones: " crlf "1 - Asistente" crlf "2 - Mostrar Cartera"  crlf "0 - salir" crlf)
  (bind ?Respuesta (read))
  (assert (Opc ?Respuesta))
)

;regla para rechazar la opción elegida por el usuario si no es una válida
(defrule rechazarOpc
  ?f <- (Opc ~1&~2&~0);si no es ninguna de las opciones disponibles
  =>
  (retract ?f)
  (assert (Menu))
)

;regla para pasar al Módulo0
(defrule iniciarAsistente
  ?f <- (Opc 1)
  =>
  (retract ?f)
  (assert (Modulo0))
)

;regla para mostrar el dinero disponible del usuario
(defrule mostrarCartera1
  (declare (salience 10)) ;mostramos en primer lugar el dinero disponible
  (Opc 2)
  (Cartera DISPONIBLE ?Cash ?)
  =>
  (printout t "Dinero disponible: " ?Cash crlf)
)

;regla para mostrar las acciones que posee el cliente
(defrule mostrarCartera2
  (Opc 2)
  (Cartera ?Empresa ?Acciones ?Valor)
  (test (neq ?Empresa DISPONIBLE))
  =>
  (printout t "Empresa: " ?Empresa " Acciones disponibles: " ?Acciones " Valor acciones: " ?Valor crlf)
)

;regla para mostrar de nuevo el menú una vez se ha mostrado la cartera del cliente
(defrule volverMenuTrasMostrarCartera
  (declare (salience -1)) ;para que se ejecute tras haber mostrado la cartera al completo
  ?f <- (Opc 2)
  =>
  (retract ?f)
  (assert (Menu))
)

;regla para abrir el fichero con la cartera del cliente para actualizarla
(defrule abrirFicheroCarteraAntesDeSalir
  (declare (salience 30))
  (Opc 0)
  =>
  (open "Cartera.txt" cartera "w")
)

;regla para almacenar la cartera del cliente en el fichero abierto
(defrule copiarDatosCartera
  (declare (salience 20))
  (Opc 0)
  (Cartera ?Empresa ?Acciones ?Valor)
  =>
  (printout cartera (str-cat ?Empresa " " ?Acciones " " ?Valor) crlf)
)

;regla para cerrar el fichero abierto y salir del programa
(defrule salir
  (declare (salience 10))
  ?f <- (Opc 0)
  =>
  (retract ?f)
  (close cartera)
  (exit)
)
