SELECT
    RESULTADO.WORK_ZONE AS BODEGA,
    RESULTADO.ARTICULO,
    RESULTADO.DESCRIPTION,
    CAST(RESULTADO.RECHAZADA AS INT) AS RECHAZADA,
    CAST(RESULTADO.DISP AS INT) AS DISP,
    CAST(RESULTADO.IT AS INT) AS IT,

    CASE
        WHEN RESULTADO.WORK_ZONE IN (
            'W-Mar Bodega 1',
            'W-Mar Bodega 2',
            'W-Mar Bodega 3',
            'W-Mar Bodega 4',
            'W-Mar Bodega 5',
            'W-Mar Bodega 6',
            'W-Mar Bodega 7',
            'W-Mar Bodega 8',
            'W-Mar Bodega 9',
            'W-Mar Vinil',
            'W-Mar Mayoreo',
            'W-Mar Primer piso Reserva'
        )
        THEN '1'

        WHEN RESULTADO.WORK_ZONE IN (
            'W-Mar Bodega 10',
            'W-Mar Bodega 11',
            'W-Mar Bodega 12',
            'W-Mar Bodega 13',
            'W-Mar Bodega 14',
            'W-Mar Bodega 15',
            'W-Mar Bodega 16',
            'W-Mar Bodega 17',
            'W-Mar Bodega 20',
            'W-Mar Bodega 21',
            'W-Mar No Banda',
            'W-Mar Segundo Piso Reserv'
        )
        THEN '2'

        ELSE '-'
    END AS PISO

FROM (

    /* =========================================================
       ARTICULOS CON CORTO
       ========================================================= */
    SELECT
        C.ITEM AS ARTICULO,
        C.DESCRIPTION,
        C.RECHAZADA,
        D.DISP,
        P.WORK_ZONE,
        P.IT

    FROM (

        SELECT
            SD.ITEM,
            REPLACE(MAX(SD.ITEM_DESC), ',', '.') AS DESCRIPTION,
            SUM(SD.TOTAL_QTY) AS RECHAZADA

        FROM shipment_detail SD

        WHERE SD.STATUS1 = 100
          AND SD.ALLOCATION_REJECTED_QTY > 0
          AND SD.COMPANY = 'FM'
          AND SD.WAREHOUSE = 'Mariano'

        GROUP BY
            SD.ITEM

    ) AS C

    /* =========================================================
       INVENTARIO DISPONIBLE
       ========================================================= */
    INNER JOIN (

        SELECT
            LI.ITEM,

            SUM(
                (LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY)
                - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)
            ) AS DISP

        FROM location_inventory LI

        INNER JOIN location L
            ON L.LOCATION = LI.LOCATION

        WHERE LI.WAREHOUSE = 'Mariano'
          AND LI.COMPANY = 'FM'
          AND L.WAREHOUSE = 'Mariano'
          AND L.LOCATION_CLASS = 'Inventory'

        GROUP BY
            LI.ITEM

        HAVING
            SUM(
                (LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY)
                - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)
            ) > 0

    ) AS D
        ON D.ITEM = C.ITEM

    /* =========================================================
       UBICACION PRIORITARIA
       ========================================================= */
    LEFT JOIN (

        SELECT
            ITEM,
            WORK_ZONE,
            IT

        FROM (

            SELECT
                LI.ITEM,
                L.WORK_ZONE,
                LI.IN_TRANSIT_QTY AS IT,

                ROW_NUMBER() OVER (
                    PARTITION BY LI.ITEM
                    ORDER BY
                        CASE
                            WHEN LI.PERMANENT = 'Y'
                                THEN 1

                            WHEN (
                                L.WORK_ZONE LIKE 'W-Mar Bodega%'
                                OR L.WORK_ZONE = 'W-Mar No Banda'
                            )
                            AND L.WORK_ZONE <> 'W-Mar Bodega Fiscal'
                                THEN 2

                            WHEN L.WORK_ZONE IS NOT NULL
                                THEN 3

                            ELSE 4
                        END
                ) AS NUM_FILA

            FROM location_inventory LI

            INNER JOIN location L
                ON L.LOCATION = LI.LOCATION

            WHERE LI.WAREHOUSE = 'Mariano'
              AND LI.COMPANY = 'FM'
              AND L.WAREHOUSE = 'Mariano'
              AND L.LOCATION_CLASS = 'Inventory'

        ) AS UBICACIONES

        WHERE NUM_FILA = 1

    ) AS P
        ON P.ITEM = C.ITEM

) AS RESULTADO

ORDER BY
    PISO,
    RESULTADO.WORK_ZONE,
    RESULTADO.ARTICULO

-- @headers: BODEGA,ARTICULO,DESCRIPTION,RECHAZADA,DISP,IT,PISO,
