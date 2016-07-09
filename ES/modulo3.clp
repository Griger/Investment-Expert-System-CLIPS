;MÓDULO 3: Detectar valores infravalorados

; Si el PER es Bajo y el RPD Alto la empresa está infravalorada
(defrule detectarInfravalorados1
	(Modulo3);hemos pasado al Módulo 3
	(DatosEmpresa (Nombre ?Nom) (EtPER Bajo) (EtRPD Alto));PER es bajo y el RPD alto
	(not (Infravalorado ?Nom ?));el valor no ha sido ya etiquetado como infravalorado
	=>
	(assert (Infravalorado ?Nom "su PER es bajo y su RPD alto"))
)

; Si la empresa ha caído bastante (más de un 30%) (en los últimos 3, 6 o 12)
; ha subido pero no mucho (menos de un 10%, supuesto por mí) en el último mes y el PER es Bajo la empresa está infravalorada
(defrule detectarInfravalorados2
	(Modulo3);hemos pasado al Módulo 3
	(DatosEmpresa (Nombre ?Nom) (EtPER Bajo) (VarMes ?VarMes) (VarTri ?VarTri) (VarSem ?VarSem) (Var12mes ?VarAno));el PER es bajo
	(not (Infravalorado ?Nom ?));el valor no ha sido ya etiquetado como infravalorado
	(and; ha subido pero no mucho en el último mes 0 < VarMes <= 10
		(test (> ?VarMes 0))
		(test (<= ?VarMes 10))
	)
	(or;ha bajado más de un 30% en los últimos 12, 6 ó 3 meses
		(test (< ?VarTri -30))
		(test (< ?VarSem -30))
		(test (< ?VarAno -30))
	)
	=>
	(assert (Infravalorado ?Nom "la empresa ha caido mas de un 30% en los ultimos 3,6 o 12 meses, ha subido un poco en el ultimo dia
	y su PER es bajo"))
)

; Si la empresa es grande, el RPD Alto y el PER Mediano, además no está bajando y se comporta
; mejor que su sector, la empresa está infravalorada.
(defrule detectarInfravalorados3
	(Modulo3);hemos pasado al Módulo 3
	;empresa grande con RPD alto y PER mediano, que no está bajando en este semana
	(DatosEmpresa (Nombre ?Nom) (Tamanio GRANDE)  (EtRPD Alto) (EtPER Medio) (Bajando5 false) (VarRespSector5 ?VarRespSectorSemana))
	(not (Infravalorado ?Nom ?));el valor no ha sido ya etiquetado como infravalorado
	(test (> ?VarRespSectorSemana 0)) ;se ha comportado mejor que sus sector esta semana
	=>
	(assert (Infravalorado ?Nom "la empresa es grande, su RPD alto, su PER mediano, ademas no esta bajando y se comporta mejor que su sector"))
)

;regla para pasar al Módulo 4.1
(defrule pasarAModulo41
	(declare (salience -1));la última regla del módulo
	?f <- (Modulo3);hemos pasado al Módulo 3
	=>
	(retract ?f)
	(assert (Modulo41))
)
