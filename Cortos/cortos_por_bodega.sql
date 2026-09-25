SELECT 
    BODEGA,
    ITEM,
    DESCRIPTION,
    RECHAZADA,
    DISP,
    IT,
    ZONA

FROM (
    SELECT
    /* HEADER */
        CAST('BODEGA' AS VARCHAR(255)) AS BODEGA,
        CAST('ITEM' AS VARCHAR(255)) AS ITEM,
        CAST('DESCRIPTION' AS VARCHAR(255)) AS DESCRIPTION,
        CAST('RECHAZADA' AS VARCHAR(255)) AS RECHAZADA,
        CAST('DISP' AS VARCHAR(255)) AS DISP,
        CAST('IT' AS VARCHAR(255)) AS IT,
        CAST('ZONA' AS VARCHAR(255)) AS ZONA,
        0 AS ORDEN

    UNION ALL

    SELECT
    /* DATOS */
        CAST(RESULTADO.WORK_ZONE AS VARCHAR(255)) AS BODEGA,
        CAST(RESULTADO.ITEM AS VARCHAR(255)) AS ITEM,
        CAST(RESULTADO.DESCRIPTION AS VARCHAR(255)) AS DESCRIPTION,
        CAST(CAST(RESULTADO.RECHAZADA AS INT) AS VARCHAR(255)) AS RECHAZADA,
        CAST(CAST(RESULTADO.DISP AS INT) AS VARCHAR(255)) AS DISP,
        CAST(CAST(RESULTADO.IT AS INT) AS VARCHAR(255)) AS IT,

        CAST(CASE
            WHEN RESULTADO.WORK_ZONE IN 
                ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9', 'W-Mar Vinil', 'W-Mar Mayoreo')
                THEN '1'

            WHEN RESULTADO.WORK_ZONE IN 
                ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar Bodega 20', 'W-Mar Bodega 21', 'W-Mar No Banda')
                THEN '2'
            ELSE '' 
            END
            AS VARCHAR(255)
        ) AS ZONA,

        1 AS ORDEN

    FROM (

        SELECT
            CORTOS.ITEM AS ITEM,
            CORTOS.DESCRIPTION,
            CORTOS.RECHAZADA,
            DISPONIBLE.DISP,
            PRIORIDAD.WORK_ZONE,
            PRIORIDAD.IT

        FROM (
            /* CORTOS */
            SELECT
                SD.ITEM,
                REPLACE(SD.ITEM_DESC, ',', '.') AS DESCRIPTION,
                SUM(SD.TOTAL_QTY) AS RECHAZADA

            FROM shipment_detail SD

            WHERE SD.STATUS1 = 100
            AND SD.ALLOCATION_REJECTED_QTY > 0
            AND SD.COMPANY = 'FM'
            AND SD.WAREHOUSE = 'Mariano'

            GROUP BY
                SD.ITEM,
                SD.ITEM_DESC

        ) AS CORTOS

        /* DISPONIBLE */
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

            AND L.LOCATION NOT IN (
                'MERMA-00',
                'MERMA-01',
                'MERMA-02',
                'MERMA-03',
                'INTERNET-01'
            )


            GROUP BY
                LI.ITEM

            HAVING
                SUM(
                    (LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY)
                    - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)
                ) > 0

        ) AS DISPONIBLE
            ON DISPONIBLE.ITEM = CORTOS.ITEM

        /* UBICACIÓN PRIORITARIA */
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

        ) AS PRIORIDAD
            ON PRIORIDAD.ITEM = CORTOS.ITEM

    ) AS RESULTADO
    
) AS RESULT

ORDER BY
    ORDEN, ZONA, BODEGA, ITEM

-- @headers: BODEGA,ITEM,DESCRIPTION,RECHAZADA,DISP,IT,PISO,
