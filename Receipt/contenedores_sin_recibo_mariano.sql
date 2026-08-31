SELECT
    SC.parent_container_id AS CONTAINER_ID,
    SC.item AS ITEM,
    CAST(SC.quantity AS INT) AS QUANTITY,
    ILA.allocation_loc AS LOC_PERMANENT,
    CONTAINER.CONTAINER_TULTI,
    CONTAINER.DATE_STAMP,
    CONTAINER.SHIPMENT_ID

FROM shipping_container SC

LEFT JOIN (

    SELECT
        ITEM,
        ALLOCATION_LOC

    FROM (
        SELECT
            ITEM,
            ALLOCATION_LOC,
            ROW_NUMBER() OVER (
                PARTITION BY ITEM
                ORDER BY ALLOCATION_LOC
            ) AS NUM_FILA

        FROM item_location_assignment

        WHERE quantity_um = 'PZ'
    ) AS ASIGNACIONES

    WHERE NUM_FILA = 1
) AS ILA
    ON ILA.ITEM = SC.ITEM

INNER JOIN (
    SELECT
        TUL.CONTAINER_ORIGINAL,
        TUL.CONTAINER_TULTI,
        TUL.DATE_STAMP,
        TUL.SHIPMENT_ID

    FROM (
        SELECT
            SC.container_id AS CONTAINER_ORIGINAL,

            CASE
                WHEN RIGHT(SC.container_id, 1) = 'P'
                    THEN LEFT(SC.container_id, LEN(SC.container_id) - 1)
                ELSE SC.container_id
            END AS CONTAINER_TULTI,

            DATEADD(HOUR, -6, SH.date_time_stamp) AS DATE_STAMP,
            SH.shipment_id AS SHIPMENT_ID

        FROM shipping_container SC

        INNER JOIN shipment_header SH
            ON SC.internal_shipment_num = SH.internal_shipment_num

        WHERE SC.warehouse = 'Tultitlan'
          AND SC.status = 900
          AND SH.order_type = 'TR-TUL-ME'
          AND SH.shipment_id LIKE 'E-%'
          AND SC.container_id IS NOT NULL
    ) AS TUL

    WHERE NOT EXISTS (
        SELECT 1
        FROM receipt_container RC
        WHERE RC.container_id = TUL.CONTAINER_TULTI
          AND RC.receipt_id LIKE 'TR_E-%'
          AND RC.parent = 0
    )
) AS CONTAINER
    ON CONTAINER.CONTAINER_ORIGINAL = SC.parent_container_id

WHERE SC.warehouse = 'Tultitlan'

  AND CONTAINER.DATE_STAMP > DATEADD(DAY, -7, GETDATE())

ORDER BY
    CONTAINER.DATE_STAMP,
    SC.parent_container_id,
    SC.item

-- @headers: PARENT_CONTAINER_ID,ITEM,QUANTITY,LOC_PERMANENT,CONTAINER,DATE_STAMP,SHIPMENT_ID,
