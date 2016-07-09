;MÓDULO 2: detector de valores sobrevalorados

; Si el PER es Alto y el RPD Bajo la empresa está sobrevalorada.
(defrule detectarSobrevalorados1
	(Modulo2) ;hemos pasado al Módulo 2
	(DatosEmpresa (Nombre ?Nom) (EtPER Alto) (EtRPD Bajo)) ;PER es Alto y el RPD Bajo
	(not (Sobrevalorado ?Nom ?));el valor no ha sido ya etiquetado como sobrevalorado
	=>
	(assert (Sobrevalorado ?Nom "su PER es alto y su RPD bajo"))
)

; Caso empresa pequeña: Si el PER es Alto la empresa está sobrevalorada.
(defrule detectarSobrevalorados2
	(Modulo2);hemos pasado al Módulo 2
	(DatosEmpresa (Nombre ?Nom) (Tamanio PEQUENIA) (EtPER Alto));empresa pequeña con PER alto
	(not (Sobrevalorado ?Nom ?));el valor no ha sido ya etiquetado como sobrevalorado
	=>
	(assert (Sobrevalorado ?Nom "es pequena y su PER es alto"))
)

; Caso empresa pequeña: Si el PER es Mediano y el RPD Bajo la empresa está sobrevalorada.
(defrule detectarSobrevalorados3
	(Modulo2);hemos pasado al Módulo 2
	(DatosEmpresa (Nombre ?Nom) (Tamanio PEQUENIA) (EtPER Medio) (EtRPD Bajo));empresa pequeña con PER mediano y RPD bajo
	(not (Sobrevalorado ?Nom ?));el valor no ha sido ya etiquetado como sobrevalorado
	=>
	(assert (Sobrevalorado ?Nom "es pequena, su PER es mediano y su RPD bajo"))
)

; Caso empresa grande: Si el RPD es Bajo y el PER es Mediano o Alto la empresa está sobrevalorada.
(defrule detectarSobrevalorados4
	(Modulo2);hemos pasado al Módulo 2
	(DatosEmpresa (Nombre ?Nom) (Tamanio GRANDE) (EtRPD Bajo) (EtPER Medio|Alto));empresa grande con RPD bajo y PER mediano o alto.
	(not (Sobrevalorado ?Nom ?));el valor no ha sido ya etiquetado como sobrevalorado
	=>
	(assert (Sobrevalorado ?Nom "es grande, su PER no es pequeno y su RPD bajo"))
)

; Caso empresa grande: Si el RPD es Mediano y el PER Alto la empresa está sobrevalorada.
(defrule detectarSobrevalorados5
	(Modulo2);hemos pasado al Módulo 2
	(DatosEmpresa (Nombre ?Nom) (Tamanio GRANDE) (EtRPD Medio) (EtPER Alto));empresa grande con RPD mediano y PER alto
	(not (Sobrevalorado ?Nom ?));el valor no ha sido ya etiquetado como sobrevalorado
	=>
	(assert (Sobrevalorado ?Nom "es grande, su PER es alto y su RPD mediano"))
)

;regla para pasar al Módulo 3
(defrule pasarAModulo3
	(declare (salience -1)) ;última regla del módulo
	?f <- (Modulo2);hemos pasado al Módulo 2
	=>
	(retract ?f)
	(assert (Modulo3))
)
