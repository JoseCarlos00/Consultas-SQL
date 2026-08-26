SELECT
    LOCATION,
    LOCATION_TYPE,
    VALIDACION,
    MOTIVO,
    ALLOCATION_ZONE,
    WORK_ZONE,
    LOCATING_ZONE,
    MULTI_ITEM,
    TRACK_CONTAINERS,
    ALLOCATE_IN_TRANSIT,
    STATUS

FROM (
    SELECT
        LOCATION,
        LOCATION_TYPE,
        ALLOCATION_ZONE,
        WORK_ZONE,
        LOCATING_ZONE,
        MULTI_ITEM,
        TRACK_CONTAINERS,
        ALLOCATE_IN_TRANSIT,
        LOCATION_STS AS STATUS,

        /* VALIDACION GENERAL */
        CASE

            /* Generica Permanente R
               No se valida configuración */
            WHEN LOCATION_TYPE = 'Generica Permanente R'
                THEN 'Reserva Permanente'


            /* Generica Dinamico R */
            WHEN LOCATION_TYPE = 'Generica Dinamico R'
                 AND (ALLOCATION_ZONE IS NULL OR ALLOCATION_ZONE NOT IN ('A-Surtido Dinamico', 'A-Surtido Permanente'))
                 AND MULTI_ITEM = 'Y'
                 AND TRACK_CONTAINERS = 'Y'
                 AND ALLOCATE_IN_TRANSIT = 'N'
                THEN 'Correcto'


            /* Generica Permanente S */
            WHEN LOCATION_TYPE = 'Generica Permanente S'
                 AND ALLOCATION_ZONE IS NOT NULL
                 AND ALLOCATION_ZONE = 'A-Surtido Permanente'
                 AND MULTI_ITEM = 'N'
                 AND TRACK_CONTAINERS = 'N'
                 AND ALLOCATE_IN_TRANSIT = 'Y'
                THEN 'Correcto'


            /* Generica Dinamico S */
            WHEN LOCATION_TYPE = 'Generica Dinamico S'
                 AND (ALLOCATION_ZONE IS NULL OR ALLOCATION_ZONE = 'A-Surtido Dinamico')
                 AND MULTI_ITEM = 'Y'
                 AND TRACK_CONTAINERS = 'N'
                 AND ALLOCATE_IN_TRANSIT = 'N'
                THEN 'Correcto'


            ELSE 'Incorrecto'

        END AS VALIDACION,


        /*
           MOTIVO
           Muestra TODOS los atributos incorrectos
           */
        CASE
            WHEN LOCATION_TYPE = 'Generica Permanente R'
                THEN 'No aplica validacion'

            WHEN LOCATION_TYPE = 'Generica Dinamico R'
                THEN
                    CASE
                        WHEN
                            (
                                (ALLOCATION_ZONE IS NULL OR ALLOCATION_ZONE IN ('A-Surtido Dinamico', 'A-Surtido Permanente'))
                                OR MULTI_ITEM <> 'Y'
                                OR TRACK_CONTAINERS <> 'Y'
                                OR ALLOCATE_IN_TRANSIT <> 'N'
                            )
                        THEN
                            STUFF(
                                CASE
                                    WHEN (ALLOCATION_ZONE IS NULL OR ALLOCATION_ZONE IN ('A-Surtido Dinamico','A-Surtido Permanente'))
                                    THEN ' | ALLOCATION_ZONE no permitido'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN MULTI_ITEM <> 'Y'
                                        THEN ' | MULTI_ITEM debe ser Y'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN TRACK_CONTAINERS <> 'Y'
                                        THEN ' | TRACK_CONTAINERS debe ser Y'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN ALLOCATE_IN_TRANSIT <> 'N'
                                        THEN ' | ALLOCATE_IN_TRANSIT debe ser N'
                                    ELSE ''
                                END,
                                1, 3, ''
                            )
                        ELSE 'OK'
                    END

            WHEN LOCATION_TYPE = 'Generica Permanente S'
                THEN
                    CASE
                        WHEN
                            ALLOCATION_ZONE IS NULL
                            OR ALLOCATION_ZONE <> 'A-Surtido Permanente'
                            OR MULTI_ITEM <> 'N'
                            OR TRACK_CONTAINERS <> 'N'
                            OR ALLOCATE_IN_TRANSIT <> 'Y'
                        THEN
                            STUFF(
                                CASE
                                    WHEN ALLOCATION_ZONE IS NULL
                                        THEN ' | ALLOCATION_ZONE es NULL'
                                    WHEN ALLOCATION_ZONE <> 'A-Surtido Permanente'
                                        THEN ' | ALLOCATION_ZONE debe ser A-Surtido Permanente'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN MULTI_ITEM <> 'N'
                                        THEN ' | MULTI_ITEM debe ser N'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN TRACK_CONTAINERS <> 'N'
                                        THEN ' | TRACK_CONTAINERS debe ser N'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN ALLOCATE_IN_TRANSIT <> 'Y'
                                        THEN ' | ALLOCATE_IN_TRANSIT debe ser Y'
                                    ELSE ''
                                END,
                                1, 3, ''
                            )
                        ELSE 'OK'
                    END

            WHEN LOCATION_TYPE = 'Generica Dinamico S'
                THEN
                    CASE
                        WHEN
                           (ALLOCATION_ZONE IS NULL OR ALLOCATION_ZONE <> 'A-Surtido Dinamico')
                            OR MULTI_ITEM <> 'Y'
                            OR TRACK_CONTAINERS <> 'N'
                            OR ALLOCATE_IN_TRANSIT <> 'N'
                        THEN
                            STUFF(
                                CASE
                                    WHEN (ALLOCATION_ZONE IS NULL OR ALLOCATION_ZONE <> 'A-Surtido Dinamico')
                                        THEN ' | ALLOCATION_ZONE debe ser A-Surtido Dinamico'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN MULTI_ITEM <> 'Y'
                                        THEN ' | MULTI_ITEM debe ser Y'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN TRACK_CONTAINERS <> 'N'
                                        THEN ' | TRACK_CONTAINERS debe ser N'
                                    ELSE ''
                                END
                                +
                                CASE
                                    WHEN ALLOCATE_IN_TRANSIT <> 'N'
                                        THEN ' | ALLOCATE_IN_TRANSIT debe ser N'
                                    ELSE ''
                                END,
                                1, 3, ''
                            )
                        ELSE 'OK'
                    END

            ELSE 'Tipo de ubicacion no contemplado'
        END AS MOTIVO
        


    FROM location

    WHERE warehouse = 'Mariano'
        AND location_class = 'Inventory'
        -- AND LOCATION LIKE '_-__-__-__-__'
        AND LOCATION_TYPE IN ('Generica Dinamico R', 'Generica Dinamico S', 'Generica Permanente R', 'Generica Permanente S')

) AS PRINCIPAL

WHERE VALIDACION = 'Incorrecto'

ORDER BY
    LOCATION_TYPE,
    VALIDACION,
    MOTIVO,
    LOCATION;
