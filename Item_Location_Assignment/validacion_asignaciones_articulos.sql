SELECT
    item AS ITEM,
    company,
    quantity_um,
    warehouse,
    allocation_loc,
    CNT_ASIGNACIONES,

    CASE
        WHEN item IS NULL
            THEN 'ITEM NULL'

        WHEN company IS NULL
            THEN 'COMPANY NULL'

        WHEN quantity_um IS NULL
            THEN 'QUANTITY_UM NULL'

        WHEN warehouse IS NULL
            THEN 'WAREHOUSE NULL'

        WHEN allocation_loc IS NULL
            THEN 'ALLOCATION_LOC NULL'

        WHEN CNT_ASIGNACIONES > 1
            THEN 'MULTIPLES ASIGNACIONES'

        WHEN quantity_um <> 'PZ'
             AND NOT (
                 item LIKE '4110-%'
                 OR item LIKE '1310-%'
                 OR item LIKE '1346-%'
             )
            THEN 'DEBE SER PZ'

        WHEN quantity_um <> 'CJ'
             AND (
                 item LIKE '4110-%'
                 OR item LIKE '1310-%'
                 OR item LIKE '1346-%'
             )
            THEN 'ITEM EXCEPCION: DEBE SER CJ'

        ELSE 'OK'
    END AS PROBLEMA

FROM
(
    SELECT
        ila.*,
        COUNT(*) OVER (PARTITION BY item) AS CNT_ASIGNACIONES
    FROM item_location_assignment ila
) AS A

WHERE
       item IS NULL
    OR company IS NULL
    OR quantity_um IS NULL
    OR warehouse IS NULL
    OR allocation_loc IS NULL
    OR CNT_ASIGNACIONES > 1

    OR (
        quantity_um <> 'PZ'
        AND NOT (
            item LIKE '4110-%'
            OR item LIKE '1310-%'
            OR item LIKE '1346-%'
        )
    )

    OR (
        quantity_um <> 'CJ'
        AND (
            item LIKE '4110-%'
            OR item LIKE '1310-%'
            OR item LIKE '1346-%'
        )
    )

ORDER BY
    item,
    allocation_loc;
