SELECT 
    L.work_zone, 
    L.location,
    I.item,
    I.ITEM_COLOR,
    CAST(((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS INT) AS AV,
    CAST(LI.ON_HAND_QTY AS INT) AS OH,
    CAST(LI.ALLOCATED_QTY AS INT) AS AL,
    CAST(LI.IN_TRANSIT_QTY AS INT) AS IT,
    CAST(LI.SUSPENSE_QTY AS INT) AS SU,
    CAST(ILC.MAXIMUM_QTY AS INT) AS QTY,
    NUEVA = NULL,
    ILC.quantity_um

FROM location_inventory LI
LEFT JOIN item_location_capacity ILC ON ILC.item = LI.item 
INNER JOIN location L ON L.location = LI.location    
INNER JOIN item I ON I.item = LI.item   

WHERE I.company='FM'    
AND (ILC.location_type NOT LIKE 'Generica Permanente R' 
        OR  ILC.location_type IS NULL)
AND L.location_type='Generica Permanente S'
-- AND L.location LIKE '1-60-%'
AND L.work_zone='W-Mar Bodega 6'

ORDER BY L.location, I.item

-- WORK_ZONE,LOCATION,ITEM,COLOR,AV,OH,AL,IT,SU,QTY,NUEVA,UM,