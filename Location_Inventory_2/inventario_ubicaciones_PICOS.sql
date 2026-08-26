SELECT
    WORK_ZONE,
    LOCATION,
    ITEM,
    DESCRIPTION,
    OH,
    CAJAS,
    PICKING,
    ZONA
FROM
(
    /* HEADER */
    SELECT
        CAST('WORK_ZONE' AS VARCHAR(255)) AS WORK_ZONE,
        CAST('LOCATION' AS VARCHAR(255)) AS LOCATION,
        CAST('ITEM' AS VARCHAR(255)) AS ITEM,
        CAST('DESCRIPTION' AS VARCHAR(255)) AS DESCRIPTION,
        CAST('OH' AS VARCHAR(255)) AS OH,
        CAST('CAJAS' AS VARCHAR(255)) AS CAJAS,
        CAST('PICKING' AS VARCHAR(255)) AS PICKING,
        CAST('ZONA' AS VARCHAR(255)) AS ZONA,
        0 AS ORDEN

    UNION ALL

    /* DATOS */
    SELECT
        CAST(PRINCIPAL.WORK_ZONE AS VARCHAR(255)),
        CAST(PRINCIPAL.LOCATION AS VARCHAR(255)),
        CAST(PRINCIPAL.ITEM AS VARCHAR(255)),
        CAST(PRINCIPAL.DESCRIPTION AS VARCHAR(255)),
        CAST(CAST(SUM(PRINCIPAL.OH) AS INT) AS VARCHAR(255)),
        CAST(CAJAS AS VARCHAR(255)),
        CAST(PICKING AS VARCHAR(255)),
        CAST(ZONA AS VARCHAR(255)),
        1 AS ORDEN

    FROM
    (
        SELECT
            ZONAS.WORK_ZONE AS WORK_ZONE,
            LI.LOCATION AS LOCATION,
            LI.ITEM AS ITEM,
            REPLACE(LI.ITEM_DESC, ',', '.') AS DESCRIPTION,

            CASE
                WHEN WORK_ZONE IN
                (
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
                    'W-Mar Mayoreo'
                )
                THEN '1'

                WHEN WORK_ZONE IN
                (
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
                    'W-Mar No Banda'
                )
                THEN '2'

                ELSE ''
            END AS ZONA,

            SUM(LI.ON_HAND_QTY) AS OH,

            CAST(
                SUM(LI.ON_HAND_QTY) / UOM.conversion_qty
                AS DECIMAL(5,2)
            ) AS CAJAS,

            LI.internal_location_inv,

            ILA.allocation_loc AS PICKING

        FROM location_inventory LI

        LEFT OUTER JOIN item_unit_of_measure UOM
            ON LI.ITEM = UOM.item
            AND UOM.sequence = '2'
            AND UOM.company = 'FM'

        LEFT OUTER JOIN
        (
            SELECT
                ITEM,
                WORK_ZONE,
                LOCATION,
                AV,
                OH,
                AL,
                IT,
                SU,
                NumFila

            FROM
            (
                SELECT
                    CASE
                        WHEN
                            (
                                l.work_zone LIKE 'W-Mar Bodega%'
                                OR l.work_zone = 'W-Mar No Banda'
                            )
                            AND l.work_zone <> 'W-Mar Bodega Fiscal'
                        THEN l.work_zone
                        ELSE ''
                    END AS WORK_ZONE,

                    li.item AS ITEM,

                    CASE
                        WHEN
                            l.location_type LIKE 'Generica%S'
                            AND l.location NOT LIKE '0-%'
                        THEN l.location

                        WHEN
                            (
                                li.item LIKE '4110-%'
                                OR li.item LIKE '1310-%'
                                OR li.item LIKE '1346-%'
                            )
                        THEN l.location

                        ELSE ''
                    END AS LOCATION,

                    ROW_NUMBER() OVER
                    (
                        PARTITION BY li.item
                        ORDER BY
                            CASE
                                WHEN li.permanent = 'Y'
                                    THEN 1

                                WHEN
                                    (
                                        l.work_zone LIKE 'W-Mar Bodega%'
                                        OR l.work_zone = 'W-Mar No Banda'
                                    )
                                    AND l.work_zone <> 'W-Mar Bodega Fiscal'
                                    THEN 2

                                WHEN l.work_zone IS NOT NULL
                                    THEN 3

                                ELSE 4
                            END
                    ) AS NumFila,

                    (
                        (
                            LI.on_hand_qty
                            + LI.in_transit_qty
                        )
                        -
                        (
                            LI.allocated_qty
                            + LI.suspense_qty
                        )
                    ) AS AV,

                    on_hand_qty AS OH,
                    allocated_qty AS AL,
                    in_transit_qty AS IT,
                    suspense_qty AS SU

                FROM location_inventory li

                INNER JOIN location l
                    ON l.location = li.location

                WHERE li.warehouse = 'Mariano'
                  AND l.location_type LIKE 'Generica%S'

            ) AS FILAS

            WHERE NumFila = 1

        ) AS ZONAS
            ON ZONAS.item = LI.ITEM

        LEFT OUTER JOIN item_location_assignment ILA
            ON ILA.item = LI.item
            AND ILA.company = 'FM'
            AND ILA.quantity_um = 'PZ'

        WHERE LI.warehouse = 'Mariano'
          AND LI.location LIKE 'PICOS%'
          AND LI.ON_HAND_QTY > 0

        GROUP BY
            ZONAS.WORK_ZONE,
            LI.LOCATION,
            LI.ITEM,
            LI.ITEM_DESC,
            WORK_ZONE,
            LI.ON_HAND_QTY,
            LI.internal_location_inv,
            UOM.conversion_qty,
            ILA.allocation_loc

    ) AS PRINCIPAL

    GROUP BY
        PRINCIPAL.WORK_ZONE,
        PRINCIPAL.LOCATION,
        PRINCIPAL.ITEM,
        PRINCIPAL.DESCRIPTION,
        CAJAS,
        PICKING,
        ZONA

) AS RESULTADO

ORDER BY
    ORDEN, WORK_ZONE, ITEM;
