;MÓDULO 0

;hechos iniciales del programa
(deffacts Contadores
  (NumPropuestas 0)
  (Ids 0)
	(PrecioDinero 0)
)

;templates para almacenar los datos de empresas y de sectores
(deftemplate DatosEmpresa
	(field Nombre)
	(field Precio (type NUMBER))
	(field VarDia (type NUMBER))
	(field Capital (type NUMBER))
	(field PER (type NUMBER))
	(field RPD (type NUMBER))
	(field Tamanio (type SYMBOL) (allowed-symbols PEQUENIA MEDIANA GRANDE))
	(field Ibex (type NUMBER))
	(field EtPER (type SYMBOL) (allowed-symbols Alto Medio Bajo))
	(field EtRPD (type SYMBOL) (allowed-symbols Alto Medio Bajo))
	(field Sector)
	(field Var5 (type NUMBER))
	(field Bajando3 (type SYMBOL) (allowed-symbols true false))
	(field Bajando5 (type SYMBOL) (allowed-symbols true false))
	(field VarRespSector5 (type NUMBER))
	(field VRS5 (type SYMBOL) (allowed-symbols true false))
	(field VarMes (type NUMBER))
	(field VarTri (type NUMBER))
	(field VarSem (type NUMBER))
	(field Var12mes (type NUMBER))
)

(deftemplate DatosSector
	(field Nombre)
	(field VarDia (type NUMBER))
	(field Capital (type NUMBER))
	(field PER (type NUMBER))
	(field RPD (type NUMBER))
	(field Ibex (type NUMBER))
	(field Var5 (type NUMBER))
	(field Bajando3 (type SYMBOL) (allowed-symbols true false))
	(field Bajando5 (type SYMBOL) (allowed-symbols true false))
	(field VarMes (type NUMBER))
	(field VarTri (type NUMBER))
	(field VarSem (type NUMBER))
	(field Var12mes (type NUMBER))
)

;REGLAS PARA CARGAR LOS DATOS DE LAS EMPRESAS

;regla para abrir el archivo con los datos de las empresas
(defrule abrirficheroemp
	(declare (salience 30))
	=>
	(open "Analisis.txt" datosemp)
	(assert (SeguirLeyendo DatosEmpresa))
)

;regla que lee cada una de las líneas del fichero con los datos de la empresa y las almacena en la forma de hechos DatosEmpresa
(defrule leervalorescierreemp
	(declare (salience 20))
	?f <- (SeguirLeyendo DatosEmpresa)
	=>
	(bind ?Dato (read datosemp))
	(if (neq ?Dato EOF) then ;si no hemos llegado al final del fichero
		(assert (DatosEmpresa
		 					(Nombre ?Dato)
							(Precio (read datosemp))
							(VarDia (read datosemp))
							(Capital (read datosemp))
							(PER (read datosemp))
							(RPD (read datosemp))
							(Tamanio (read datosemp))
							(Ibex (read datosemp))
							(EtPER (read datosemp))
							(EtRPD (read datosemp))
							(Sector (read datosemp))
							(Var5 (read datosemp))
							(Bajando3 (read datosemp))
							(Bajando5 (read datosemp))
							(VarRespSector5 (read datosemp))
							(VRS5 (read datosemp))
							(VarMes (read datosemp))
							(VarTri (read datosemp))
							(VarSem (read datosemp))
							(Var12mes (read datosemp))
						)
		)
    (retract ?f)
    (assert (SeguirLeyendo DatosEmpresa)) ;decimos que hemos de seguir leyendo el fichero tras leer una línea
    else
    (retract ?f)
  )
)

;regla que cierra el fichero de datos de las empresa una vez que se ha completado su lectura
(defrule cerrarficheroemp
  (declare (salience 10))
  =>
  (close datosemp)
)

;REGLAS PARA LEER DATOS DE SECTORES

;regla que abre el fichero con los datos sobre los sectores
(defrule abrirficherosec
	(declare (salience 30))
	=>
	(open "AnalisisSectores.txt" datossec)
	(assert (SeguirLeyendoSec))
)

;regla que lee cada una de las líneas del fichero con los datos de los sectores y las almacena en hechos del tipo DatosSector
(defrule leervalorescierresec
	(declare (salience 20))
	?f <- (SeguirLeyendoSec)
	=>
	(bind ?Dato (read datossec))
	(if (neq ?Dato EOF) then ;si no hemos llegado al final del fichero
		(assert (DatosSector
		 					(Nombre ?Dato)
							(VarDia (read datossec))
							(Capital (read datossec))
							(PER (read datossec))
							(RPD (read datossec))
							(Ibex (read datossec))
							(Var5 (read datossec))
							(Bajando3 (read datossec))
							(Bajando5 (read datossec))
							(VarMes (read datossec))
							(VarTri (read datossec))
							(VarSem (read datossec))
							(Var12mes (read datossec))
						)
		)
    (retract ?f)
    (assert (SeguirLeyendoSec)) ;decimos que hemos de leer la siguien línea
    else
    (retract ?f)
  )
)

;regla que cierra el fichero de datos de los sectores una vez que se ha completado su lectura
(defrule cerrarficherosec
  (declare (salience 10))
  =>
  (close datossec)
)

;REGLAS PARA CARGAR LA CARTERA DEL USUARIO

;regla que abre el fichero con los datos sobre la cartera del usuario
(defrule abrirficherocartera
	(declare (salience 30))
	=>
	(open "Cartera.txt" cartera)
	(assert (SeguirLeyendo Cartera))
)

;regla que lee cada línea del fichero con los datos de la cartera y las almecena en forma de hechos Cartera
(defrule leercartera
	(declare (salience 20))
	?f <- (SeguirLeyendo Cartera)
	=>
	(bind ?Dato (read cartera))
	(if (neq ?Dato EOF) then ;si no hemos llegado al final del fichero
		(assert (Cartera ?Dato (read cartera) (read cartera)))

    (retract ?f)
    (assert (SeguirLeyendo Cartera)) ; decimo que hemos de leer la siguiente línea
    else
    (retract ?f)
  )
)

;regla que cierra el fichero de datos de la cartera una vez que se ha completado su lectura
(defrule cerrarficherocar
  (declare (salience 10))
  =>
  (close cartera)
)

;REGLAS PARA CARGAR LAS NOTICIAS

;regla que abre el fichero con las distintas noticias de interés para el SE
(defrule abrirficheronoticias
	(declare (salience 30))
	=>
	(open "Noticias.txt" noticias)
	(assert (SeguirLeyendo Noticias))
)

;regla que lee cada línea del fichero de noticias almecenándolas en hechos del tipo Noticia
(defrule leernoticias
	(declare (salience 20))
	?f <- (SeguirLeyendo Noticias)
	=>
	(bind ?Dato (read noticias))
	(if (neq ?Dato EOF) then ;si no hemos llegado al final del fichero
		(assert (Noticia ?Dato (read noticias)))

    (retract ?f)
    (assert (SeguirLeyendo Noticias)) ;decimos que hemos de leer la siguiente línea
    else
    (retract ?f)
  )
)

;regla que cierra el fichero con las distintas noticias una vez que se ha completado su lectura
(defrule cerrarficheronoticias
  (declare (salience 10))
  =>
  (close noticias)
)

(defrule mostrarMenuTrasCarga
  (declare (salience -1))
  =>
  (assert (Menu))
)

;REGLAS PARA DEDUCIR VALORES INESTABLES

;Los valores del sector de la construcción son inestables por defecto
(defrule contruccionInestableDefecto
  (Modulo0)
	(DatosEmpresa (Sector Construccion) (Nombre ?Nom)) ;si es un valor del sector de la construcción
	(not (Inestable ?Nom ?))
	(not (QuitadosPorBuenas))
	=>
	(assert (Inestable ?Nom "es un valor del sector de la construccion"))
)

;Si la economía está bajando los valores del sector de Servicios son inestables por defecto
(defrule siEconomiaBajaServiciosInestablesDefecto
  (Modulo0)
	(DatosSector (Nombre Ibex) (Bajando3 true)) ;el Ibex representa la economía, si está bajando
	(DatosEmpresa (Sector Servicios) (Nombre ?Nom)) ;es un valor del sector Servicios
	(not (Inestable ?Nom ?)) ;el valor no ha sido ya etiquetado como inestable
	(not (QuitadosPorBuenas))
	=>
	(assert (Inestable ?Nom "la economia esta bajando y es un valor del sector Servicios"))
)

;Si hay una noticia inestable sobre un valor éste pasa a ser inestable
(defrule inestablePorNoticiasMalas1
  (Modulo0)
	(DatosEmpresa (Nombre ?Nom))
	(Noticia ?Nom mala) ;si hay una noticia mala sobre el valor
	(not (Inestable ?Nom ?)) ;el valor no ha sido ya etiquetado como inestable
	(not (QuitadosPorBuenas))
	=>
	(assert (Inestable ?Nom "ha habido una noticia mala sobre este valor, su sector o la economia"))
)

; Si hay una noticia inestable sobre su sector el valor pasa a ser inestable
(defrule inestablePorNoticiasMalas2
  (Modulo0)
	(DatosEmpresa (Nombre ?Nom) (Sector ?Sec))
	(Noticia ?Sec mala) ;hay una noticia mala sobre el sector de ?Nom
	(not (Inestable ?Nom ?)) ;el valor no ha sido ya etiquetado como inestable
	(not (QuitadosPorBuenas))
	=>
	(assert (Inestable ?Nom "ha habido una noticia mala sobre este valor, su sector o la economia"))
)

; Si hay una noticia inestable sobre la economía el valor pasa a ser inestable
(defrule inestablePorNoticiasMalas3
  (Modulo0)
	(DatosEmpresa (Nombre ?Nom))
	(Noticia Ibex mala) ;hay una noticia mala sobre la economía
	(not (QuitadosPorBuenas))
	(not (Inestable ?Nom ?)) ;el valor no ha sido ya etiquetado como inestable
	=>
	(assert (Inestable ?Nom "ha habido una noticia mala sobre este valor, su sector o la economia"))
)

;Si hay una noticia buena sobre él o su sector el valor pasa a ser estable
(defrule establePorNoticiasBuenas
  (declare (salience -1))
  (Modulo0)
	(DatosEmpresa (Nombre ?Nom) (Sector ?Sec))
	?f <- (Inestable ?Nom ?) ;si fue marcado como inestable
	(or ;si hay una noticia sobre el valor o su sector
		(Noticia ?Nom buena)
		(and (Noticia ?Sec buena) (not (Noticia ?Nom mala))) ;prioridad a noticias del propio valor
	)
	=>
	(assert (QuitadosPorBuenas))
	(retract ?f)
)

;regla para pasar al Modulo1
(defrule pasarAModulo1
  (declare (salience -10)) ;se ejecuta como la última regla de este módulo, cuando finaliza la acción de éste
  ?f <- (Modulo0)
	=>
  (retract ?f)
	(assert (Modulo1 0))
)
