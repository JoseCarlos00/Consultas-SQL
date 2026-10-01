SELECT 
    -- SC.ITEM,CAST(SC.QTY - COALESCE(LI.ON_HAND_QTY, 0) AS INT) AS QTY_FALTANTE, LOC='EMP-01'
    LI.LOCATION,
    SC.QTY - COALESCE(LI.ON_HAND_QTY, 0) AS QTY_FALTANTE,
    SC.ITEM,
    COALESCE(LI.ON_HAND_QTY, 0) AS ON_HAND_QTY,
    LI.ALLOCATED_QTY,
    LI.IN_TRANSIT_QTY,
    SC.QTY AS SC_QTY

FROM (
    SELECT
        ITEM,
        SUM(Quantity) AS QTY

    FROM shipping_container
    WHERE status IN (401, 600)
        AND warehouse = 'Mariano'
        AND container_id IS NULL
        -- AND parent_container_id = 'FMA00034532'
        
    GROUP BY ITEM
) AS SC

LEFT JOIN location_inventory LI
    ON SC.ITEM = LI.ITEM
    AND LI.warehouse = 'Mariano'
    AND LI.location = 'EMP-01'
WHERE 
    LI.ITEM IS NULL
    OR SC.QTY > LI.ON_HAND_QTY;
